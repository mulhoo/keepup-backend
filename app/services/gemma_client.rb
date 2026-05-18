require "net/http"
require "json"

# HTTP wrapper for the Gemma 4 FastAPI microservice.
# All calls are fire-and-forget safe — a timeout or service error raises
# GemmaClient::ServiceUnavailable, which callers rescue to degrade gracefully.
class GemmaClient
  ServiceUnavailable = Class.new(StandardError)

  DEFAULT_TIMEOUT    = (Rails.application.config.gemma.dig(:moderation, :timeout_seconds) || 60).to_i
  GENERATION_TIMEOUT = 60
  MAX_ATTEMPTS       = 2
  RETRY_DELAY        = 0.25 # seconds

  def self.post(path, body, timeout: DEFAULT_TIMEOUT)
    new.post(path, body, timeout: timeout)
  end

  ServerError = Class.new(StandardError)

  def post(path, body, timeout: DEFAULT_TIMEOUT)
    attempt = 0

    begin
      attempt += 1
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      uri = URI("#{service_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl      = uri.scheme == "https"
      http.open_timeout = timeout
      http.read_timeout = timeout

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req["Accept"]       = "application/json"
      req.body            = body.to_json

      response   = http.request(req)
      latency_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round

      unless response.is_a?(Net::HTTPSuccess)
        raise ServerError, "HTTP #{response.code}" if response.code.to_i >= 500
        raise ServiceUnavailable, "Gemma service returned #{response.code} for #{path}"
      end

      Rails.logger.info("[GemmaClient] #{path} ok attempt=#{attempt} latency=#{latency_ms}ms")
      JSON.parse(response.body, symbolize_names: true)

    rescue ServerError => e
      if attempt < MAX_ATTEMPTS
        Rails.logger.warn("[GemmaClient] #{path} #{e.message} attempt=#{attempt} — retrying in #{RETRY_DELAY}s")
        sleep(RETRY_DELAY)
        retry
      end
      raise ServiceUnavailable, "Gemma service returned server error for #{path}"
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError,
           IO::TimeoutError => e
      if attempt < MAX_ATTEMPTS
        Rails.logger.warn("[GemmaClient] #{path} #{e.class} attempt=#{attempt} — retrying in #{RETRY_DELAY}s")
        sleep(RETRY_DELAY)
        retry
      end
      Rails.logger.error("[GemmaClient] #{path} unreachable after #{attempt} attempt(s): #{e.message}")
      raise ServiceUnavailable, "Gemma service unreachable (#{path}): #{e.message}"
    end
  end

  private

  def service_url
    Rails.application.config.gemma[:service_url]
  end
end
