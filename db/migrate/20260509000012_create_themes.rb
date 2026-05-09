class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string  :name,    null: false
      t.integer :scope,   null: false, default: 0
      t.integer :variant, null: false
      t.references :school,     null: true, foreign_key: true
      t.references :created_by, null: true, foreign_key: { to_table: :users }

      # ── Semantic color slots ──────────────────────────────────────────────────
      # Each slot maps to a specific UI role. The mobile app references these by
      # column name — never by position — so the mapping never drifts.

      t.string :color_background,      null: false  # Main screen background
      t.string :color_surface,         null: false  # Cards, panels, message bubbles
      t.string :color_surface_variant, null: false  # Input fields, modals, secondary panels
      t.string :color_border,          null: false  # Borders, dividers, separators
      t.string :color_primary,         null: false  # Nav bar, headers, key structural elements
      t.string :color_accent,          null: false  # Buttons, active states, unread badges, links
      t.string :color_text_primary,    null: false  # Body text, headings
      t.string :color_text_secondary,  null: false  # Timestamps, captions, placeholders
      t.string :color_text_on_primary, null: false  # Text/icons on color_primary surfaces
      t.string :color_text_on_accent,  null: false  # Text on accent-colored buttons

      t.boolean :active, null: false, default: true
      t.timestamps
    end

    # A school can have at most one dark theme and one light theme — DB-enforced
    add_index :themes, [ :school_id, :variant ],
              unique: true,
              where: "scope = 1",
              name: "index_themes_on_school_id_and_variant_unique"

    add_index :themes, :scope
    add_index :themes, :active
  end
end
