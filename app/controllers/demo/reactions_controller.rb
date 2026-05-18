module Demo
  class ReactionsController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :load_message

    # POST /demo/messages/:message_id/reactions
    # Toggles a reaction — adds if not present, removes if present.
    def toggle
      emoji = params[:emoji].to_s.strip
      return render json: { error: "emoji is required" }, status: :bad_request if emoji.blank?
      return render json: { error: "Invalid emoji" }, status: :bad_request if emoji.length > 50

      existing = @message.reactions.find_by(user: current_user, emoji: emoji)
      if existing
        existing.destroy!
        reacted = false
      else
        @message.reactions.create!(user: current_user, emoji: emoji)
        reacted = true
      end

      render json: serialize_reactions(@message, reacted_emoji: emoji, reacted: reacted)
    end

    private

    def load_message
      @message = Message.find_by(id: params[:message_id])
      return render json: { error: "Not found" }, status: :not_found unless @message
      render json: { error: "Not authorized" }, status: :forbidden unless @message.channel.viewable_by?(current_user)
    end

    def serialize_reactions(message, reacted_emoji: nil, reacted: nil)
      grouped = message.reactions.includes(:user).group_by(&:emoji)
      grouped.map do |emoji, reactions|
        {
          emoji:   emoji,
          count:   reactions.size,
          reacted: reactions.any? { |r| r.user_id == current_user.id },
          users:   reactions.map { |r| r.user.first_name }
        }
      end
    end
  end
end
