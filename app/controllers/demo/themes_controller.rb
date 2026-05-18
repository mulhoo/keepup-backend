module Demo
  class ThemesController < ApplicationController
    include DemoGuard
    before_action :require_demo_mode
    before_action :require_can_theme, only: [ :generate ]

    def index
      themes = Theme.available_to(current_user).order(:scope, :name)
      render json: themes.map { |t|
        {
          id:          t.id,
          name:        t.name,
          scope:       t.scope,
          variant:     t.variant,
          school_name: t.school&.name,
          colors:      t.color_palette
        }
      }
    end

    def generate
      school_colors = params[:school_colors].to_s.strip
      return render json: { error: "School colors are required" }, status: :unprocessable_entity if school_colors.blank?

      render json: ThemeColorizer.generate(school_colors).merge(source: "fallback")
    end

    private

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end

    def require_can_theme
      role = current_user.institution_roles.first&.role.to_s
      unless %w[athletic_director school_admin].include?(role)
        render json: { error: "Forbidden" }, status: :forbidden
      end
    end
  end
end

# Deterministic fallback when Gemma is unavailable.
# Parses color names from plain English, maps to hex, and derives full dark + light palettes.
module ThemeColorizer
  # Multi-word phrases matched first (longest-first to avoid partial hits)
  PHRASES = {
    "forest green"  => "#228b22",
    "hunter green"  => "#355e3b",
    "kelly green"   => "#4cbb17",
    "olive green"   => "#556b2f",
    "lime green"    => "#32cd32",
    "dark green"    => "#145a32",
    "baby blue"     => "#6baed6",
    "sky blue"      => "#6caed6",
    "powder blue"   => "#b0c4de",
    "carolina blue" => "#4b9cd3",
    "royal blue"    => "#2052a0",
    "navy blue"     => "#1b2f5b",
    "cobalt blue"   => "#1f618d",
    "light blue"    => "#6baed6",
    "dark blue"     => "#1a3a6b",
    "hot pink"      => "#e91e8c",
    "light pink"    => "#e8a0bf",
    "deep purple"   => "#4b0082",
    "dark purple"   => "#4b0082",
    "dark red"      => "#8b0000",
    "burnt orange"  => "#cc5500",
    "bright red"    => "#e74c3c"
  }.sort_by { |k, _| -k.length }.to_h.freeze

  # Single words (ambiguous modifiers like "forest" / "sky" alone are excluded)
  WORDS = {
    "red"      => "#c0392b", "crimson"  => "#a93226", "maroon"   => "#7b241c",
    "scarlet"  => "#c0392b", "cardinal" => "#922b21", "burgundy" => "#800020",
    "orange"   => "#d35400", "amber"    => "#d4ac0d",
    "yellow"   => "#d4ac0d", "gold"     => "#d4ac0d",
    "green"    => "#1e8449", "emerald"  => "#1e8449",
    "lime"     => "#27ae60", "olive"    => "#556b2f", "teal"     => "#148f77",
    "cyan"     => "#0e86d4", "aqua"     => "#0e86d4",
    "blue"     => "#1a5276", "navy"     => "#1b2f5b", "royal"    => "#2052a0",
    "cobalt"   => "#1f618d", "azure"    => "#2471a3", "indigo"   => "#2c3e8c",
    "purple"   => "#6c3483", "violet"   => "#7d3c98", "lavender" => "#9b59b6",
    "plum"     => "#6c3483", "magenta"  => "#8e44ad",
    "pink"     => "#e06090", "rose"     => "#c0392b",
    "silver"   => "#9ca3af", "gray"     => "#6b7280", "grey"     => "#6b7280",
    "black"    => "#1c2833", "charcoal" => "#2c3e50",
    "white"    => "#ffffff", "cream"    => "#fefce8",
    "brown"    => "#784212", "tan"      => "#935116", "bronze"   => "#a0522d"
  }.freeze

  NEUTRALS = %w[#ffffff #fefce8 #9ca3af #6b7280 #1c2833 #2c3e50].freeze

  def self.generate(description)
    text   = description.downcase
    found  = []

    # 1. Greedily match multi-word phrases, consuming matched text so words aren't double-counted
    remaining = text.dup
    PHRASES.each do |phrase, hex|
      next unless remaining.include?(phrase)
      found << hex
      remaining = remaining.gsub(phrase, " ")
    end

    # 2. Match remaining single words
    remaining.scan(/[a-z]+/).each do |word|
      hex = WORDS[word]
      found << hex if hex && !found.include?(hex)
    end

    found = [ WORDS["blue"], WORDS["white"] ] if found.empty?

    # 3. Chromatic colors fill named slots in priority order; neutrals fill any gaps
    chromatic = found.reject { |h| NEUTRALS.include?(h) }
    neutrals  = found.select { |h| NEUTRALS.include?(h) }
    pool      = (chromatic + neutrals).uniq

    fallback = pool[0] || WORDS["blue"]

    # Slot priority: primary, accent, border, surface_variant, surface, background
    primary         = pool[0] || fallback
    accent          = pool[1] || lighten(primary, 0.30)
    border_color    = pool[2] || nil
    surf_var_color  = pool[3] || nil
    surface_color   = pool[4] || nil
    bg_color        = pool[5] || nil

    { dark:  dark_palette(primary, accent, border_color, surf_var_color, surface_color, bg_color),
      light: light_palette(primary, accent, border_color, surf_var_color, surface_color, bg_color) }
  end

  def self.dark_palette(primary, accent, border_c, surf_var_c, surface_c, bg_c)
    {
      color_background:      bg_c       ? darken(bg_c,       0.80) : darken(primary, 0.85),
      color_surface:         surface_c  ? darken(surface_c,  0.70) : darken(primary, 0.75),
      color_surface_variant: surf_var_c ? darken(surf_var_c, 0.60) : darken(primary, 0.65),
      color_border:          border_c   ? darken(border_c,   0.35) : darken(primary, 0.45),
      color_primary:         primary,
      color_accent:          accent,
      color_text_primary:    "#f8fafc",
      color_text_secondary:  "#94a3b8",
      color_text_on_primary: light?(primary) ? "#1c2833" : "#ffffff",
      color_text_on_accent:  light?(accent)  ? "#1c2833" : "#ffffff"
    }
  end

  def self.light_palette(primary, accent, border_c, surf_var_c, surface_c, bg_c)
    {
      color_background:      bg_c       ? lighten(bg_c,       0.92) : lighten(primary, 0.94),
      color_surface:         surface_c  ? lighten(surface_c,  0.88) : "#ffffff",
      color_surface_variant: surf_var_c ? lighten(surf_var_c, 0.80) : lighten(primary, 0.88),
      color_border:          border_c   ? lighten(border_c,   0.55) : lighten(primary, 0.70),
      color_primary:         primary,
      color_accent:          accent,
      color_text_primary:    "#0f172a",
      color_text_secondary:  "#475569",
      color_text_on_primary: light?(primary) ? "#1c2833" : "#ffffff",
      color_text_on_accent:  light?(accent)  ? "#1c2833" : "#ffffff"
    }
  end

  def self.hex_to_rgb(hex)
    hex = hex.delete("#")
    [ hex[0..1].to_i(16), hex[2..3].to_i(16), hex[4..5].to_i(16) ]
  end

  def self.rgb_to_hex(r, g, b)
    "#%02x%02x%02x" % [ r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255) ]
  end

  def self.darken(hex, factor)
    r, g, b = hex_to_rgb(hex)
    rgb_to_hex((r * (1 - factor)).round, (g * (1 - factor)).round, (b * (1 - factor)).round)
  end

  def self.lighten(hex, factor)
    r, g, b = hex_to_rgb(hex)
    rgb_to_hex(
      (r + (255 - r) * factor).round,
      (g + (255 - g) * factor).round,
      (b + (255 - b) * factor).round,
    )
  end

  # Relative luminance — true if the color is light enough to need dark text on top
  def self.light?(hex)
    r, g, b = hex_to_rgb(hex).map { |c| c / 255.0 }.map { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4 }
    0.2126 * r + 0.7152 * g + 0.0722 * b > 0.35
  end
end
