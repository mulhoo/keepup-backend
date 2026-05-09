class Theme < ApplicationRecord
  COLOR_SLOTS = %i[
    color_background
    color_surface
    color_surface_variant
    color_border
    color_primary
    color_accent
    color_text_primary
    color_text_secondary
    color_text_on_primary
    color_text_on_accent
  ].freeze

  belongs_to :school, optional: true
  belongs_to :created_by, class_name: "User", optional: true
  has_many :users, dependent: :nullify

  enum :scope,   { system: 0, school: 1 }
  enum :variant, { dark: 0, light: 1 }

  validates :name, :variant, presence: true
  validates(*COLOR_SLOTS, presence: true)

  validates :school,     presence: true, if: :school?
  validates :created_by, presence: true, if: :school?

  # DB enforces uniqueness of [school_id, variant] for school-scoped themes,
  # but we validate here too for a clean error message
  validates :variant, uniqueness: {
    scope: :school_id,
    message: "already has a %{value} theme for this school"
  }, if: :school?

  validate :system_themes_have_no_school
  validate :hex_colors

  scope :available_to, ->(user) {
    school_ids = user.sport_memberships.active.select(:school_id)
    where(scope: :system)
      .or(where(scope: :school, school_id: school_ids))
      .where(active: true)
  }

  # Returns a hash of all color slots — convenient for API serialization
  def color_palette
    COLOR_SLOTS.index_with { |slot| send(slot) }
  end

  private

  def system_themes_have_no_school
    errors.add(:school, "must be blank for system themes") if system? && school_id.present?
  end

  def hex_colors
    COLOR_SLOTS.each do |slot|
      val = send(slot)
      next if val.blank?
      errors.add(slot, "must be a valid hex color (e.g. #1B2F5B)") unless val.match?(/\A#[0-9A-Fa-f]{6}\z/)
    end
  end
end
