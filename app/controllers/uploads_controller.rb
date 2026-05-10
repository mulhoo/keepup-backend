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
    raise Pundit::NotAuthorizedError unless policy.public_send(:"#{resource_type}?")

    key = S3KeyBuilder.build(resource_type:, record:, filename:)
    return render json: { error: "Could not generate upload path" }, status: :unprocessable_entity unless key

    presigned_url = presigner.presigned_url(
      :put_object,
      bucket:      bucket_name,
      key:,
      expires_in:  PRESIGN_TTL,
      content_type:
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
    # Uses the SDK credential chain — no explicit keys needed:
    #   - Local dev: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY from .env
    #   - ECS production: IAM task role via instance metadata (no keys anywhere)
    @s3_client ||= Aws::S3::Client.new(region: aws_region)
  end

  def bucket_name
    @bucket_name ||= ENV.fetch("S3_BUCKET")
  end

  def aws_region
    @aws_region ||= ENV.fetch("AWS_REGION", "us-east-2")
  end
end
