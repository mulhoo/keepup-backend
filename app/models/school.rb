class School < ApplicationRecord
  belongs_to :district

  has_many :institution_roles, dependent: :destroy
  has_many :coop_authorizations, dependent: :destroy
  has_many :sports, through: :coop_authorizations


  validates :name, presence: true, uniqueness: { scope: :district_id }
  validates :icon_url,   format: { with: URI::DEFAULT_PARSER.make_regexp(%w[https]), message: "must be a valid HTTPS URL" }, allow_blank: true
  validates :banner_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[https]), message: "must be a valid HTTPS URL" }, allow_blank: true

  scope :active, -> { where(active: true) }

  def athletic_directors
    institution_roles.athletic_director.includes(:user).map(&:user)
  end

  def school_admins
    institution_roles.school_admin.includes(:user).map(&:user)
  end
end
