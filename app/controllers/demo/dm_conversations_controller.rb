module Demo
  class DmConversationsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    # GET /demo/dm_conversations/startable?season_id=X
    # Returns users the current user is permitted to DM in the given season.
    def startable
      season_id = params[:season_id]
      return render json: { error: "season_id is required" }, status: :bad_request unless season_id.present?

      season = Season.find_by(id: season_id)
      return render json: { error: "Season not found" }, status: :not_found unless season

      school       = season.school
      current_sm   = current_user.season_memberships.find_by(season:)
      current_role = current_sm&.role
      current_is_ad = ad_school&.id == school.id

      seen_ids = []
      seen_ids << current_user.id
      result   = []

      # Season members (excluding self)
      SeasonMembership.active
                      .where(season:)
                      .where.not(user_id: current_user.id)
                      .includes(:user)
                      .sort_by { |sm| sm.user.last_name }
                      .each do |sm|
        next if excluded_dm_partner?(current_role, current_user, sm.role, sm.user)
        seen_ids << sm.user_id
        result << { id: sm.user_id, name: sm.user.full_name, role: sm.role }
      end

      # ADs at this school (they have no season membership)
      unless current_is_ad
        InstitutionRole.athletic_director
                       .where(school_id: school.id)
                       .where.not(user_id: current_user.id)
                       .includes(:user)
                       .each do |ir|
          next if seen_ids.include?(ir.user_id)
          seen_ids << ir.user_id
          result << { id: ir.user_id, name: ir.user.full_name, role: "athletic_director" }
        end
      end

      render json: result.sort_by { |r| r[:name] }
    end

    # POST /demo/dm_conversations
    # Finds or creates a DM conversation; returns the conversation in the same shape as index.
    def create
      season = Season.find_by(id: params[:season_id])
      return render json: { error: "Season not found" }, status: :not_found unless season

      other = User.find_by(id: params[:other_user_id])
      return render json: { error: "User not found" }, status: :not_found unless other

      conv = DmConversation.between(current_user, other, season)

      other_role = season.season_memberships.find_by(user: other)&.role
      other_role ||= "athletic_director" if other.institution_roles.athletic_director.exists?

      last_dm = conv.direct_messages.order(created_at: :desc).first
      unread  = conv.direct_messages.where.not(sender_id: current_user.id).where(read_at: nil).count

      render json: {
        id:              conv.id,
        season_id:       conv.season_id,
        other_user:      { id: other.id, first_name: other.first_name, last_name: other.last_name, role: other_role },
        last_message:    last_dm&.content,
        last_message_at: conv.last_message_at,
        unread_count:    unread
      }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def index
      season_id = params[:season_id]
      return render json: { error: "season_id is required" }, status: :bad_request unless season_id.present?

      conversations = DmConversation
                        .where(season_id: season_id)
                        .where("participant_a_id = :id OR participant_b_id = :id", id: current_user.id)
                        .includes(:participant_a, :participant_b)
                        .order(last_message_at: :desc)

      season = Season.find_by(id: season_id)

      render json: conversations.map { |conv|
        other    = conv.other_participant(current_user)
        last_dm  = conv.direct_messages.order(created_at: :desc).first
        unread   = conv.direct_messages
                       .where.not(sender_id: current_user.id)
                       .where(read_at: nil)
                       .count
        other_role = season&.season_memberships&.find_by(user: other)&.role

        {
          id:           conv.id,
          season_id:    conv.season_id,
          other_user: {
            id:         other.id,
            first_name: other.first_name,
            last_name:  other.last_name,
            role:       other_role
          },
          last_message:    last_dm&.content,
          last_message_at: conv.last_message_at,
          unread_count:    unread
        }
      }
    end

    def mark_read
      conv = find_authorized_conversation
      return unless conv

      conv.direct_messages
          .where.not(sender_id: current_user.id)
          .where(read_at: nil)
          .update_all(read_at: Time.current)

      render json: { ok: true }
    end

    def messages
      conv = find_authorized_conversation
      return unless conv

      dms = conv.direct_messages
                .where(deleted_at: nil)
                .where("flag_action IS NULL OR flag_action != 'blocked' OR sender_id = ?", current_user.id)
                .order(created_at: :asc)
                .limit(100)
                .includes(:sender, :reply_to)

      render json: dms.map { |dm| serialize_dm(dm) }
    end

    def send_message
      conv = find_authorized_conversation
      return unless conv

      content = params[:content].to_s.strip
      return render json: { error: "Content can't be blank" }, status: :unprocessable_entity if content.blank?

      reply_to = params[:reply_to_id].present? ? conv.direct_messages.find_by(id: params[:reply_to_id]) : nil

      dm     = conv.direct_messages.build(sender: current_user, content: content, reply_to: reply_to)
      result = moderate_dm(content, conv)
      Gemma::ContentModerator.call(dm, score: result[:score], reason: result[:reason], category: result[:category])
      dm.save!

      tier = dm_tier(dm)
      Rails.logger.info("[Demo::DMs] moderation source=#{result[:source]} score=#{result[:score].round(3)} tier=#{tier} conversation=#{conv.id} dm=#{dm.id}")
      ModerationNotificationJob.perform_later("DirectMessage", dm.id, tier) if dm.flagged?

      render json: {
        message:    serialize_dm(dm),
        moderation: {
          score:                 result[:score],
          tier:                  tier,
          flag_action:           dm.flag_action,
          notifications_sent_to: dm_notification_recipients(conv, tier)
        }
      }, status: :created
    end

    def report_dm_message
      conv = find_authorized_conversation
      return unless conv

      dm = conv.direct_messages.find_by(id: params[:message_id])
      return render json: { error: "Message not found" }, status: :not_found unless dm

      notes = params[:notes].to_s.strip

      unless dm.flag_action == "blocked"
        dm.update!(
          flagged:      true,
          flag_action:  "held",
          flag_reason:  dm.flag_reason.presence || "Reported by user",
          report_notes: notes.presence
        )
      else
        dm.update!(report_notes: notes.presence) if notes.present?
      end

      ModerationNotificationJob.perform_later("DirectMessage", dm.id, "questionable")

      render json: { reported: true, message_id: dm.id }, status: :ok
    end

    private

    # Returns true if the pairing is blocked for the current user.
    def excluded_dm_partner?(my_role, me, their_role, them)
      return !me.parents.exists?(id: them.id)  if my_role == "student" && their_role == "parent"
      return !me.children.exists?(id: them.id) if my_role == "parent"  && their_role == "student"
      false
    end

    def find_authorized_conversation
      conv = DmConversation.find_by(id: params[:id])
      unless conv
        render json: { error: "Conversation not found" }, status: :not_found
        return nil
      end
      unless conv.participant?(current_user)
        render json: { error: "Not authorized" }, status: :forbidden
        return nil
      end
      conv
    end

    def moderate_dm(content, conv)
      sport             = conv.season.sport
      sport_template_id = sport.sport_template_id
      school_id         = sport.school_id

      # COPPA/FERPA boundary: never route student content to server-side AI moderation
      sender_role = conv.season.season_memberships.find_by(user_id: current_user.id)&.role
      if sender_role == "student"
        return Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_fallback")
      end

      response = GemmaClient.post("/moderate", { content:, sender_role: })
      { score: response[:score].to_f, reason: response[:reason], category: response[:category], source: "gemma4" }
    rescue GemmaClient::ServiceUnavailable
      Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_fallback")
    end

    def dm_tier(dm)
      return "severe"       if dm.flag_action == "blocked"
      return "questionable" if dm.flag_action == "held"
      "clear"
    end

    def dm_notification_recipients(conv, tier)
      return [] unless tier != "clear"
      season  = conv.season
      coaches = season.head_coaches.map { |u| { role: "head_coach", name: u.full_name } }
      ad      = InstitutionRole.athletic_director.find_by(school: season.school)&.user
      coaches.tap { |r| r << { role: "athletic_director", name: ad.full_name } if tier == "severe" && ad }
    end

    def serialize_dm(dm)
      is_sender = dm.sender_id == current_user.id
      blocked   = dm.flag_action == "blocked"

      reply_preview = if dm.reply_to
        {
          id:      dm.reply_to.id,
          sender:  dm.reply_to.sender.full_name,
          content: dm.reply_to.content
        }
      end

      {
        id:          dm.id,
        content:     blocked ? (is_sender ? "[Your message was blocked 🚫]" : nil) : dm.content,
        sender:      dm.sender.full_name,
        sender_id:   dm.sender_id,
        flag_action: dm.flag_action,
        flagged:     dm.flagged,
        created_at:  dm.created_at.iso8601,
        reactions:   [],
        reply_count: 0,
        reply_to:    reply_preview
      }
    end
  end
end
