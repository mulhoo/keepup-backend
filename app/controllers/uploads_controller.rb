require "aws-sdk-s3"
require "s3_key_builder"

class UploadsController < ApplicationController
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_FILE_SIZE         = 5.megabytes.to_i
  PRESIGN_TTL           = 300 # seconds

  RESOURCE_TYPES = %w[school_icon school_banner profile_photo sport_emoji].freeze

  def presign
    resource_type = params.require(:resource_type)
    resource_id   = params.require(:resource_id).to_i
    filename      = params.require(:filename).to_s.strip
    content_type  = params.require(:content_type).to_s.strip

    unless RESOURCE_TYPES.include?(resource_type)
      return render json: { error: "Unknown resource type" }, status: :unprocessable_entity
    end

    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      return render json: { error: "Content type not permitted" }, status: :unprocessable_entity
    end

    record = find_record(resource_type, resource_id)
    return render json: { error: "Not found" }, status: :not_found unless record

    policy = UploadPolicy.new(current_user, record)
    action = :"#{resource_type}?"
    raise Pundit::NotAuthorizedError unless policy.public_send(action)

    key = S3KeyBuilder.build(resource_type:, record:, filename:)
    return render json: { error: "Could not generate upload path" }, status: :unprocessable_entity unless key

    presigned_url = presigner.presigned_url(
      :put_object,
      bucket:         bucket_name,
      key:,
      expires_in:     PRESIGN_TTL,
      content_type:,
      content_length_range: 1..MAX_FILE_SIZE
    )

    render json: {
      presigned_url:,
      key:,
      public_url: "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{key}"
    }
  end

  private

  def find_record(resource_type, resource_id)
    case resource_type
    when "school_icon", "school_banner" then School.find_by(id: resource_id)
    when "profile_photo"                then User.active.find_by(id: resource_id)
    when "sport_emoji"                  then Sport.find_by(id: resource_id)
    end
  end

  def presigner
    @presigner ||= Aws::S3::Presigner.new(client: s3_client)
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region:      aws_region,
      credentials: Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    )
  end

  def bucket_name
    @bucket_name ||= Rails.application.credentials.dig(:aws, :s3_bucket)
  end

  def aws_region
    @aws_region ||= Rails.application.credentials.dig(:aws, :region) || "us-east-1"
  end
end
