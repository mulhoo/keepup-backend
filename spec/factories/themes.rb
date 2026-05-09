FactoryBot.define do
  factory :theme do
    sequence(:name) { |n| "Test Theme #{n}" }
    scope                   { :system }
    variant                 { :dark }
    color_background        { "#0D1B2A" }
    color_surface           { "#1B2F5B" }
    color_surface_variant   { "#162444" }
    color_border            { "#2A4170" }
    color_primary           { "#1B2F5B" }
    color_accent            { "#00E5CC" }
    color_text_primary      { "#FFFFFF" }
    color_text_secondary    { "#A0B4CC" }
    color_text_on_primary   { "#FFFFFF" }
    color_text_on_accent    { "#0D1B2A" }
    active                  { true }

    trait :light do
      variant               { :light }
      color_background      { "#FFFFFF" }
      color_surface         { "#F0F4F8" }
      color_surface_variant { "#E2EAF4" }
      color_border          { "#C8D6E8" }
      color_text_primary    { "#0D1B2A" }
      color_text_secondary  { "#5A6E88" }
    end

    trait :school_theme do
      scope      { :school }
      school     { association :school }
      created_by { association :user }
    end
  end
end
