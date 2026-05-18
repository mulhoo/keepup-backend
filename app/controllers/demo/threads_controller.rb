module Demo
  class ThreadsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :load_parent_message

    # GET /demo/messages/:message_id/thread
    def show
      thread  = @parent_message.message_thread_as_parent
      replies = thread ? thread.messages.includes(sender: [ :institution_roles, :season_memberships ], reactions: :user)
                                        .where(deleted_at: nil)
                                        .where("flag_action IS NULL OR flag_action != 'blocked'")
                                        .order(created_at: :asc) : []

      render json: {
        parent_message: serialize_message(@parent_message),
        reply_count:    thread&.reply_count || 0,
        replies:        replies.map { |m| serialize_message(m) }
      }
    end

    # POST /demo/messages/:message_id/thread
    def create
      content = params[:content].to_s.strip
      return render json: { error: "Content can't be blank" }, status: :unprocessable_entity if content.blank?

      thread = MessageThread.find_or_create_by!(
        channel:        @parent_message.channel,
        parent_message: @parent_message
      )

      reply = thread.messages.build(
        channel: @parent_message.channel,
        sender:  current_user,
        content: content,
      )

      result = moderate(reply.content)
      Gemma::ContentModerator.call(reply, score: result[:score], reason: result[:reason], category: result[:category])
      reply.save!

      thread.update!(reply_count: thread.messages.count, last_reply_at: Time.current)

      tier = moderation_tier(reply)
      Rails.logger.info("[Demo::Threads] moderation source=#{result[:source]} score=#{result[:score].round(3)} tier=#{tier} parent=#{@parent_message.id} reply=#{reply.id}")
      ModerationNotificationJob.perform_later("Message", reply.id, tier) if reply.flagged?

      render json: serialize_message(reply), status: :created
    end

    private

    def load_parent_message
      @parent_message = Message.includes(sender: [ :institution_roles, :season_memberships ], reactions: :user)
                               .find_by(id: params[:message_id])
      return render json: { error: "Not found" }, status: :not_found unless @parent_message
      render json: { error: "Not authorized" }, status: :forbidden unless @parent_message.channel.viewable_by?(current_user)
    end

    def moderation_tier(msg)
      return "severe"       if msg.flag_action == "blocked"
      return "questionable" if msg.flag_action == "held"
      "clear"
    end

    def moderate(content)
      channel           = @parent_message.channel
      sport             = channel.season&.sport
      sport_template_id = sport&.sport_template_id
      school_id         = sport&.school_id

      inst = current_user.institution_roles.min_by(&:id)
      sender_role = if inst
        inst.role.to_s
      else
        current_user.season_memberships.find_by(season_id: channel.season_id)&.role.to_s
      end

      # COPPA/FERPA: student content stays on-device
      if sender_role == "student"
        return Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_fallback")
      end

      response = GemmaClient.post("/moderate", { content:, sender_role: })
      { score: response[:score].to_f, reason: response[:reason], category: response[:category], source: "gemma4" }
    rescue GemmaClient::ServiceUnavailable
      Demo::KeywordModerator.score(content, sport_template_id:, school_id:).merge(source: "keyword_fallback")
    end

    STAFF_ROLES = %w[head_coach assistant_coach].freeze

    def sender_role_for(msg)
      sender = msg.sender
      inst = sender.institution_roles.min_by(&:id)
      return inst.role if inst
      sm = sender.season_memberships.find { |m| m.season_id == @parent_message.channel.season_id }
      return nil unless sm
      sm.student? && sm.is_captain? ? "student_captain" : sm.role
    end

    def display_name_for(sender, role)
      return sender.full_name unless %w[student student_captain].include?(role)
      case sender.name_display
      when "first_only"         then sender.first_name
      when "first_last_initial" then "#{sender.first_name} #{sender.last_name[0]}."
      else sender.full_name
      end
    end

    def serialize_message(msg)
      role   = sender_role_for(msg)
      sender = msg.sender

      reactions = msg.reactions.group_by(&:emoji).map do |emoji, rxns|
        { emoji: emoji, count: rxns.size, reacted: rxns.any? { |r| r.user_id == current_user.id }, users: rxns.map { |r| r.user.first_name } }
      end

      {
        id:              msg.id,
        content:         msg.content,
        sender:          display_name_for(sender, role),
        sender_id:       msg.sender_id,
        sender_role:     role,
        sender_pronouns: sender.pronouns.presence,
        created_at:      msg.created_at.iso8601,
        flagged:         msg.flagged,
        flag_action:     msg.flag_action,
        reactions:       reactions,
        reply_count:     msg.message_thread_as_parent&.reply_count || 0
      }
    end
  end
end
