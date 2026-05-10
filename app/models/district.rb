class District < ApplicationRecord
  has_many :schools, dependent: :destroy
  has_many :institution_roles, dependent: :destroy
  has_many :sport_templates, dependent: :destroy
  has_many :sport_commissionerships, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :city, :state, :country, presence: true

  scope :active, -> { where(active: true) }

  def admins
    institution_roles.district_admin.includes(:user).map(&:user)
  end

  def dpa_contacts
    institution_roles.dpa_contact.includes(:user).map(&:user)
  end
end
