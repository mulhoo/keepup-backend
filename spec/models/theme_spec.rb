require "rails_helper"

RSpec.describe Theme, type: :model do
  describe "validations" do
    it "is valid with all required fields" do
      expect(build(:theme)).to be_valid
    end

    it "requires all 10 color slots" do
      Theme::COLOR_SLOTS.each do |slot|
        expect(build(:theme, slot => nil)).not_to be_valid,
          "expected theme with #{slot}: nil to be invalid"
      end
    end

    it "validates hex color format on every slot" do
      Theme::COLOR_SLOTS.each do |slot|
        expect(build(:theme, slot => "not-a-color")).not_to be_valid
        expect(build(:theme, slot => "#ZZZ000")).not_to be_valid
        expect(build(:theme, slot => "#1B2F5B")).to be_valid
      end
    end

    context "school-scoped themes" do
      let(:school) { create(:school) }
      let(:ad)     { create(:user) }

      it "requires school and created_by" do
        expect(build(:theme, :school_theme, school: nil)).not_to be_valid
        expect(build(:theme, :school_theme, created_by: nil)).not_to be_valid
      end

      it "enforces one dark and one light per school" do
        create(:theme, :school_theme, school: school, created_by: ad, variant: :dark)
        duplicate = build(:theme, :school_theme, school: school, created_by: ad, variant: :dark)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:variant]).to be_present
      end

      it "allows one dark and one light for the same school" do
        create(:theme, :school_theme, school: school, created_by: ad, variant: :dark)
        light = build(:theme, :school_theme, :light, school: school, created_by: ad)
        expect(light).to be_valid
      end

      it "does not enforce the variant limit across different schools" do
        other_school = create(:school)
        create(:theme, :school_theme, school: school, created_by: ad, variant: :dark)
        expect(build(:theme, :school_theme, school: other_school, created_by: ad, variant: :dark)).to be_valid
      end
    end

    it "does not allow school_id on system themes" do
      school = create(:school)
      expect(build(:theme, scope: :system, school: school)).not_to be_valid
    end
  end

  describe ".available_to" do
    let(:school)  { create(:school) }
    let(:sport)   { create(:sport, school: school) }
    let(:user)    { create(:user) }
    let!(:system_dark)  { create(:theme, name: "System Dark") }
    let!(:school_theme) { create(:theme, :school_theme, school: school, variant: :dark, created_by: create(:user)) }
    let!(:other_theme)  { create(:theme, :school_theme, school: create(:school), variant: :dark, created_by: create(:user)) }

    context "when the user has no sport memberships" do
      it "returns only system themes" do
        expect(Theme.available_to(user)).to include(system_dark)
        expect(Theme.available_to(user)).not_to include(school_theme, other_theme)
      end
    end

    context "when the user belongs to the school" do
      before { create(:sport_membership, user: user, sport: sport, school: school, role: :student) }

      it "returns system themes and their school theme" do
        expect(Theme.available_to(user)).to include(system_dark, school_theme)
        expect(Theme.available_to(user)).not_to include(other_theme)
      end
    end
  end

  describe "User#theme_available_to_user" do
    let(:school)       { create(:school) }
    let(:sport)        { create(:sport, school: school) }
    let(:other_school) { create(:school) }
    let(:ad)           { create(:user) }
    let(:user)         { create(:user) }
    let(:school_theme) { create(:theme, :school_theme, school: school, created_by: ad, variant: :dark) }
    let(:other_theme)  { create(:theme, :school_theme, school: other_school, created_by: ad, variant: :dark) }

    before { create(:sport_membership, user: user, sport: sport, school: school, role: :student) }

    it "allows selecting a theme from the user's school" do
      user.theme = school_theme
      expect(user).to be_valid
    end

    it "rejects a theme from a school the user doesn't belong to" do
      user.theme = other_theme
      expect(user).not_to be_valid
      expect(user.errors[:theme]).to be_present
    end

    it "allows any system theme regardless of school" do
      user.theme = create(:theme, scope: :system, variant: :light, name: "Purple Light",
                          color_background: "#FAF5FF", color_surface: "#EDE9FE")
      expect(user).to be_valid
    end
  end

  describe "#color_palette" do
    it "returns a hash of all 10 color slots" do
      theme = build(:theme)
      palette = theme.color_palette
      expect(palette.keys).to match_array(Theme::COLOR_SLOTS)
      expect(palette[:color_accent]).to eq("#00E5CC")
    end
  end

  describe "User#effective_theme" do
    it "returns the assigned theme when set" do
      theme = create(:theme)
      user  = create(:user, theme: theme)
      expect(user.effective_theme).to eq(theme)
    end

    it "falls back to Default Dark when no theme is set" do
      create(:theme, name: "Default Dark", scope: :system, variant: :dark)
      user = create(:user)
      expect(user.effective_theme.name).to eq("Default Dark")
    end
  end
end
