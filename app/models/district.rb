class District < ApplicationRecord
  has_many :schools, dependent: :destroy
  has_many :institution_roles, dependent: :destroy
  has_many :sport_templates, dependent: :destroy
  has_many :sport_commissionerships, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :city, :state, :country, presence: true
  validates :subdomain, uniqueness: true, allow_nil: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }
  validates :email_domain, format: { with: /\A[a-z0-9.-]+\.[a-z]{2,}\z/, message: "must be a valid domain (e.g. lwsd.org)" }, allow_nil: true

  scope :active, -> { where(active: true) }

  def email_domain_matches?(email)
    return true if email_domain.blank?
    email.to_s.downcase.end_with?("@#{email_domain.downcase}")
  end

  def self.find_by_subdomain(slug)
    find_by(subdomain: slug&.downcase)
  end

  def admins
    institution_roles.district_admin.includes(:user).map(&:user)
  end

  def dpa_contacts
    institution_roles.dpa_contact.includes(:user).map(&:user)
  end
end
