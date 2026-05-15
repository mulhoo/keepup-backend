require "csv"

class RosterImporter
  Result = Struct.new(:added, :invited, :errors, keyword_init: true)

  ALLOWED_ROLES = %w[student parent].freeze

  CHANNEL_TYPES_FOR = {
    "student" => %w[conversation athletes_only],
    "parent"  => %w[broadcast]
  }.freeze

  def initialize(season:, rows:, invited_by:)
    @season     = season
    @district   = season.school.district
    @rows       = rows
    @invited_by = invited_by
    @added      = []
    @invited    = []
    @errors     = []
  end

  def call
    @rows.each.with_index(2) do |row, line|
      process_row(row, line)
    end
    Result.new(added: @added, invited: @invited, errors: @errors)
  end

  def self.parse_csv(file)
    CSV.parse(file.read, headers: true, header_converters: :symbol).map(&:to_h)
  end

  private

  def process_row(row, line)
    email      = row[:email]&.downcase&.strip
    role       = row[:role]&.downcase&.strip
    first_name = row[:first_name]&.strip
    last_name  = row[:last_name]&.strip
    is_captain = ActiveModel::Type::Boolean.new.cast(row[:is_captain])
    dob        = parse_date(row[:dob])

    membership_extras = {
      jersey_number: row[:jersey_number]&.strip.presence,
      grade:         row[:grade]&.strip.presence,
      level:         row[:level]&.downcase&.strip.presence,
      position:      row[:position]&.strip.presence
    }.compact

    return add_error(line, email, "Missing email") if email.blank?
    return add_error(line, email, "Invalid role '#{role}' — must be student or parent") unless ALLOWED_ROLES.include?(role)

    if role == "student" && @district.email_domain.present?
      unless @district.email_domain_matches?(email)
        return add_error(line, email, "Student email must end with @#{@district.email_domain}")
      end
    end

    user = User.active.find_by(email: email)

    if user
      add_existing_user(user, role, is_captain, dob, membership_extras, line)
    else
      invite_new_user(email, first_name, last_name, role, is_captain, dob, membership_extras, line)
    end
  end

  def add_existing_user(user, role, is_captain, dob, membership_extras, line)
    membership = @season.season_memberships.find_by(user: user)

    if membership
      return add_error(line, user.email, "#{user.full_name} is already a member of this season")
    end

    sm = @season.season_memberships.build(
      user:       user,
      role:       role,
      status:     :active,
      is_captain: is_captain && role == "student",
      **membership_extras,
    )

    unless sm.save
      return add_error(line, user.email, sm.errors.full_messages.to_sentence)
    end

    user.update!(dob:) if dob

    add_to_channels(user, role)
    @added << { email: user.email, name: user.full_name, role: role }
  end

  def invite_new_user(email, first_name, last_name, role, is_captain, dob, membership_extras, line)
    existing = Invitation.find_by(season: @season, email: email)

    if existing&.pending?
      return add_error(line, email, "Already has a pending invitation")
    end

    inv = existing || Invitation.new
    inv.assign_attributes(
      email:       email,
      first_name:  first_name,
      last_name:   last_name,
      role:        role,
      is_captain:  is_captain && role == "student",
      season:      @season,
      invited_by:  @invited_by,
      expires_at:  7.days.from_now,
      dob:,
      **membership_extras,
    )

    unless inv.save
      return add_error(line, email, inv.errors.full_messages.to_sentence)
    end

    InvitationMailer.invite(inv).deliver_later
    @invited << { email: email, role: role }
  end

  def add_to_channels(user, role)
    eligible = CHANNEL_TYPES_FOR[role] || []
    @season.channels.active.where(channel_type: eligible).each do |channel|
      channel.channel_memberships.find_or_create_by(user: user) { |m| m.role = :member }
    end
  end

  def add_error(line, email, reason)
    @errors << { line: line, email: email, reason: reason }
  end

  def parse_date(val)
    return nil if val.blank?
    Date.parse(val.to_s.strip)
  rescue ArgumentError, TypeError
    nil
  end
end
