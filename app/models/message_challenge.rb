class MessageChallenge < ApplicationRecord
  belongs_to :message
  belongs_to :challenger,  class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", upheld: "upheld", denied: "denied" }
end
