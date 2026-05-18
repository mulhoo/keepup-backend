class InvitationsController < ApplicationController
  include TokenIssuable
  skip_before_action :require_authentication

  def show
    invitation = find_valid_invitation
    render json: serialize(invitation)
  end

  def accept
    invitation = find_valid_invitation

    unless params[:password].present?
      return render json: { error: "Password is required" }, status: :unprocessable_entity
    end

    if invitation.role == "student" && invitation.dob.blank?
      return render json: { error: "Date of birth is required for student accounts" }, status: :unprocessable_entity
    end

    user = nil

    ActiveRecord::Base.transaction do
      user = User.create!(
        email:      invitation.email,
        first_name: params[:first_name].presence || invitation.first_name || "User",
        last_name:  params[:last_name].presence  || invitation.last_name  || "",
        password:   params[:password],
        active:     true,
        dob:        invitation.dob,
      )

      SeasonMembership.create!(
        user:          user,
        season:        invitation.season,
        role:          invitation.role,
        status:        :active,
        is_captain:    invitation.is_captain,
        jersey_number: invitation.jersey_number,
        grade:         invitation.grade,
        level:         invitation.level,
        position:      invitation.position,
      )

      add_to_channels(user, invitation)
      invitation.accept!(user)
    end

    token = issue_token!(user)

    render json: {
      token: token,
      user: {
        id:         user.id,
        first_name: user.first_name,
        last_name:  user.last_name,
        email:      user.email
      }
    }, status: :created
  end

  private

  def find_valid_invitation
    inv = Invitation.includes(season: { sport: :school }).find_by(token: params[:token])

    unless inv
      render json: { error: "Invitation not found." }, status: :not_found
      raise ActiveRecord::Rollback
    end

    if inv.accepted?
      render json: { error: "This invitation has already been used." }, status: :gone
      raise ActiveRecord::Rollback
    end

    unless inv.pending?
      render json: { error: "This invitation has expired." }, status: :gone
      raise ActiveRecord::Rollback
    end

    inv
  end

  CHANNEL_TYPES_FOR = {
    "student"          => %w[conversation broadcast athletes_only],
    "student_captain"  => %w[conversation broadcast athletes_only],
    "head_coach"       => %w[conversation broadcast coaches_only],
    "assistant_coach"  => %w[conversation broadcast coaches_only],
    "parent"           => %w[conversation broadcast],
  }.freeze

  def add_to_channels(user, invitation)
    eligible = CHANNEL_TYPES_FOR[invitation.role] || []
    invitation.season.channels.active.where(channel_type: eligible).each do |channel|
      channel.channel_memberships.find_or_create_by(user: user) { |m| m.role = :member }
    end
  end

  def serialize(inv)
    season = inv.season
    school = season.school
    {
      email:       inv.email,
      first_name:  inv.first_name,
      last_name:   inv.last_name,
      role:        inv.role,
      season_name: season.name,
      school_year: season.school_year,
      school_name: school.name,
      sport_name:  season.sport.name
    }
  end
end
