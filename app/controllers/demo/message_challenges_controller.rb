module Demo
  class MessageChallengesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode

    def create
      msg = Message.find_by(id: params[:message_id], flag_action: "blocked", sender: current_user)
      return render json: { error: "Not found" }, status: :not_found unless msg

      existing = MessageChallenge.where(message: msg).where.not(status: "denied").first
      return render json: { ok: true }, status: :ok if existing

      MessageChallenge.create!(
        message:    msg,
        challenger: current_user,
        reason:     params[:reason].to_s.strip.presence,
      )
      render json: { ok: true }, status: :created
    end

    def uphold
      challenge = pending_challenge
      return render json: { error: "Not found" }, status: :not_found unless challenge

      ActiveRecord::Base.transaction do
        challenge.update!(status: :upheld, reviewed_by: current_user, reviewed_at: Time.current)
        challenge.message.update!(
          flag_action:      nil,
          flag_reviewed:    true,
          flag_reviewed_by: current_user,
          flag_reviewed_at: Time.current,
        )
        BroadcastMessageJob.perform_later(challenge.message_id)
      end

      render json: { ok: true, action: "upheld" }
    end

    def deny
      challenge = pending_challenge
      return render json: { error: "Not found" }, status: :not_found unless challenge

      challenge.update!(status: :denied, reviewed_by: current_user, reviewed_at: Time.current)
      render json: { ok: true, action: "denied" }
    end

    private

    def pending_challenge
      MessageChallenge.pending
        .includes(message: { channel: { season: { sport: [ :school, :sport_template ] } } })
        .find_by(id: params[:id])
    end
  end
end
