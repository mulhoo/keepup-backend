require "rails_helper"

RSpec.describe ModerationNotificationJob do
  let(:school)      { create(:school) }
  let(:sport)       { create(:sport, school: school) }
  let(:team_level)  { create(:team_level, sport: sport) }
  let(:season)      { create(:season, sport: sport, team_level: team_level) }
  let(:head_coach)  { create(:user) }
  let(:ad_user)     { create(:user) }
  let(:student)     { create(:user) }
  let(:channel)     { create(:channel, season: season) }
  let(:message)     { create(:message, channel: channel, sender: student, flagged: true, flag_action: "blocked") }

  before do
    create(:season_membership, :head_coach, user: head_coach, season: season)
    create(:institution_role, user: ad_user, role: :athletic_director, school: school)
  end

  describe "#perform with a channel message" do
    context "for a questionable tier message" do
      it "creates a notification for the head coach only" do
        expect {
          described_class.new.perform("Message", message.id, "questionable")
        }.to change(ModerationNotification, :count).by(1)

        notification = ModerationNotification.last
        expect(notification.recipient).to eq(head_coach)
        expect(notification.notification_type).to eq("questionable_review")
        expect(notification.recipient_role).to eq("head_coach")
        expect(notification.message).to eq(message)
      end
    end

    context "for a severe tier message" do
      it "creates notifications for both head coach and athletic director" do
        expect {
          described_class.new.perform("Message", message.id, "severe")
        }.to change(ModerationNotification, :count).by(2)

        types = ModerationNotification.last(2).map(&:recipient_role)
        expect(types).to contain_exactly("head_coach", "athletic_director")
      end

      it "uses severe_alert as the notification type" do
        described_class.new.perform("Message", message.id, "severe")
        expect(ModerationNotification.pluck(:notification_type).uniq).to eq([ "severe_alert" ])
      end
    end
  end

  context "when the flagged record does not exist" do
    it "does nothing without raising" do
      expect {
        described_class.new.perform("Message", 0, "severe")
      }.not_to change(ModerationNotification, :count)
    end
  end
end
