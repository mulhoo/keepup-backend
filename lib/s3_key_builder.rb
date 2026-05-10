module S3KeyBuilder
  ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .webp .gif].freeze

  def self.build(resource_type:, record:, filename:)
    ext = File.extname(filename.to_s).downcase
    return nil unless ALLOWED_EXTENSIONS.include?(ext)

    case resource_type
    when "school_icon"
      "#{school_prefix(record)}/icon#{ext}"
    when "school_banner"
      "#{school_prefix(record)}/banner#{ext}"
    when "profile_photo"
      school = primary_school_for(record)
      return nil unless school
      "#{school_prefix(school)}/users/#{record.id}/avatar#{ext}"
    when "sport_emoji"
      "#{sport_prefix(record)}/emojis/#{SecureRandom.hex(8)}#{ext}"
    when "sport_banner"
      "#{sport_prefix(record)}/banner#{ext}"
    end
  end

  def self.school_prefix(school)
    d = school.district
    district_key = d.subdomain.presence || slug(d.name)
    "#{district_key}/#{slug(school.name)}"
  end

  def self.sport_prefix(sport)
    "#{school_prefix(sport.school)}/#{slug(sport.name)}"
  end

  def self.primary_school_for(user)
    user.season_memberships.active
        .joins(season: :sport)
        .order(created_at: :desc)
        .first
        &.season&.school
  end

  def self.slug(str)
    str.to_s.downcase.unicode_normalize(:nfd).encode("ASCII", invalid: :replace, replace: "")
        .gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
  end
end
