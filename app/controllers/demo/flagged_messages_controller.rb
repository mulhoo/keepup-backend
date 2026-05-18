module Demo
  class FlaggedMessagesController < Demo::ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def index
      questionable = held_messages_for_reviewer.map { |m| serialize(m).merge(type: "questionable") }
      challenges   = pending_challenges_for_reviewer.map { |c| serialize_challenge(c) }
      render json: (questionable + challenges).sort_by { |r| r[:created_at] }.reverse
    end

    def review
      message = held_messages_for_reviewer.find { |m| m.id == params[:id].to_i }
      return render json: { error: "Message not found or not reviewable" }, status: :not_found unless message

      action_taken = params[:action_taken].to_s
      unless %w[approved rejected].include?(action_taken)
        return render json: { error: "action_taken must be 'approved' or 'rejected'" }, status: :unprocessable_entity
      end

      ActiveRecord::Base.transaction do
        message.update!(
          flag_reviewed:    true,
          flag_reviewed_by: current_user,
          flag_reviewed_at: Time.current,
          flag_action:      action_taken == "approved" ? nil : "removed"
        )
        log_signal(message, action_taken)
      end

      BroadcastMessageJob.perform_later(message.id) if action_taken == "approved"

      render json: {
        ok:           true,
        action_taken: action_taken,
        message_id:   message.id,
            signal_stats: signal_stats_for(message)
      }
    end

    private

    def pending_challenges_for_reviewer
      MessageChallenge.pending
        .includes(:challenger, message: { channel: { season: { sport: [ :school, :sport_template ] } } })
        .select { |c| can_moderate?(c.message) }
    end

    def serialize_challenge(challenge)
      msg   = challenge.message
      sport = msg.channel.season&.sport
      {
        id:               challenge.id,
        type:             "challenge",
        content:          msg.content,
        flag_reason:      msg.flag_reason,
        moderation_score: msg.moderation_score,
        sender: {
          id:   challenge.challenger_id,
          name: challenge.challenger.full_name
        },
        challenge_reason: challenge.reason,
        sport: sport ? {
          id:          sport.id,
          name:        sport.name,
          gender:      sport.gender,
          school_name: sport.school.name
        } : nil,
        channel: {
          id:   msg.channel_id,
          name: msg.channel.name
        },
        sent_at:    msg.created_at.iso8601,
        created_at: challenge.created_at.iso8601
      }
    end

    def held_messages_for_reviewer
      Message
        .where(flag_action: "held", flag_reviewed: false)
        .includes(:sender, channel: { season: { sport: [ :school, :sport_template ] } })
        .order(created_at: :desc)
        .select { |m| can_moderate?(m) }
    end

    def moderatable_season_ids
      @moderatable_season_ids ||= begin
        inst_role = current_user.institution_roles.first
        if inst_role
          school_ids = if inst_role.super_admin?
            School.pluck(:id)
          elsif inst_role.district_admin?
            School.where(district_id: inst_role.district_id).pluck(:id)
          else
            [ inst_role.school_id ].compact
          end
          Season.joins(sport: :school).where(sports: { school_id: school_ids }).pluck(:id).to_set
        else
          current_user.season_memberships.active
                      .where(role: %w[head_coach assistant_coach])
                      .pluck(:season_id).to_set
        end
      end
    end

    def can_moderate?(message)
      return false if message.sender_id == current_user.id
      season = message.channel&.season
      return false unless season
      moderatable_season_ids.include?(season.id)
    end

    def log_signal(message, action_taken)
      sport = message.channel.season&.sport
      return unless sport

      category = message.flag_category.presence || "unknown"

      SafetyReviewSignal.create!(
        school_id:         sport.school_id,
        sport_template_id: sport.sport_template_id,
        category:          category,
        decision:          action_taken == "approved" ? :approved : :rejected,
        sender_role:       sender_role_for(message),
        channel_type:      message.channel.channel_type,
        gemma_confidence:  message.moderation_score&.to_f,
      )
    rescue => e
      Rails.logger.warn("[FlaggedMessages] Could not log signal: #{e.message}")
    end

    def signal_stats_for(message)
      sport    = message.channel.season&.sport
      category = message.flag_category.presence
      return nil unless sport && category

      signals  = SafetyReviewSignal.recent.where(
        school_id:         sport.school_id,
        sport_template_id: sport.sport_template_id,
        category:          category
      )
      total    = signals.count
      approved = signals.where(decision: :approved).count

      {
        category:      category,
        total:         total,
        approved:      approved,
        approval_rate: total > 0 ? (approved.to_f / total).round(3) : nil
      }
    end

    def sender_role_for(message)
      sender = message.sender
      return "head_coach"      if sender.season_memberships.where(role: :head_coach).exists?
      return "assistant_coach" if sender.season_memberships.where(role: :assistant_coach).exists?
      return "student"         if sender.season_memberships.where(role: :student).exists?
      "unknown"
    end

    def serialize(message)
      sport = message.channel.season&.sport
      {
        id:               message.id,
        content:          message.content,
        flag_category:    message.flag_category,
        flag_reason:      message.flag_reason,
        report_notes:     message.report_notes,
        moderation_score: message.moderation_score,
        sender: {
          id:   message.sender_id,
          name: message.sender.full_name
        },
        sport: sport ? {
          id:          sport.id,
          name:        sport.name,
          gender:      sport.gender,
          school_name: sport.school.name
        } : nil,
        channel: {
          id:   message.channel_id,
          name: message.channel.name
        },
        sent_at:    message.created_at.iso8601,
        created_at: message.created_at.iso8601
      }
    end
  end
end
