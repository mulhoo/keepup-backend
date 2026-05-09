class DeviceToken < ApplicationRecord
  belongs_to :user

  enum :platform, { ios: "ios", android: "android" }

  validates :token, presence: true, uniqueness: true
  validates :platform, presence: true

  scope :active, -> { where(active: true) }

  def self.register(user:, token:, platform: "ios")
    find_or_initialize_by(token:).tap do |dt|
      dt.update!(user:, platform:, active: true)
    end
  end

  def self.deactivate(token)
    find_by(token:)&.update!(active: false)
  end
end
