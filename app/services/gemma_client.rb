require "net/http"
require "json"

# HTTP wrapper for the Gemma 4 FastAPI microservice.
# All calls are fire-and-forget safe — a timeout or service error raises
# GemmaClient::ServiceUnavailable, which callers rescue to degrade gracefully.
class GemmaClient
  ServiceUnavailable = Class.new(StandardError)

  TIMEOUT = (Rails.application.config.gemma.dig(:moderation, :timeout_seconds) || 5).to_i

  def self.post(path, body)
    new.post(path, body)
  end

  def post(path, body)
    uri = URI("#{service_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = TIMEOUT
    http.read_timeout = TIMEOUT

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    request.body = body.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise ServiceUnavailable, "Gemma service returned #{response.code} for #{path}"
    end

    JSON.parse(response.body, symbolize_names: true)
  rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, SocketError => e
    raise ServiceUnavailable, "Gemma service unreachable (#{path}): #{e.message}"
  end

  private

  def service_url
    Rails.application.config.gemma[:service_url]
  end
end
