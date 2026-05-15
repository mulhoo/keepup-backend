# Seed data for local development — HSD (Hajos School District) demo scenario.
# Run with: bin/rails db:seed
# Safe to re-run: structural records use find_or_create_by!; mutable demo state
# is explicitly reset so every demo run (including "End Demo") starts clean.

puts "Seeding KeepUp development data..."

# Mutable demo state — wiped on every seed run so every demo starts clean.
ParentViewRequest.destroy_all
MessageChallenge.destroy_all
SafetyReviewSignal.destroy_all
CommissionerEvent.delete_all
Venue.delete_all
QualificationFlag.delete_all
MeetResult.delete_all
TimeStandard.delete_all
Channel.family_group.each { |fg| fg.messages.destroy_all }
Notification.update_all(read_at: nil)
ModerationNotification.update_all(read_at: nil)
# Restore any reviewed messages back to held/unreviewed so the Reviews queue
# always has content when the demo starts.
Message.where(flag_reviewed: true).update_all(
  flag_action:         "held",
  flag_reviewed:       false,
  flag_reviewed_by_id: nil,
  flag_reviewed_at:    nil,
)

# ── District ──────────────────────────────────────────────────────────────────

hsd = District.find_or_create_by!(name: "Hajos School District") do |d|
  d.city    = "Riverside"
  d.state   = "WA"
  d.country = "US"
  d.active  = true
end

# ── Schools ───────────────────────────────────────────────────────────────────

ahs = School.find_or_create_by!(name: "Alfred High School", district: hsd) do |s|
  s.city   = "Riverside"
  s.state  = "WA"
  s.active = true
end

bhs = School.find_or_create_by!(name: "Baldwin High School", district: hsd) do |s|
  s.city   = "Riverside"
  s.state  = "WA"
  s.active = true
end

chs = School.find_or_create_by!(name: "Crest High School", district: hsd) do |s|
  s.city   = "Riverside"
  s.state  = "WA"
  s.active = true
end

# ── System Themes ─────────────────────────────────────────────────────────────
# Each preset ships as a dark + light pair. These are global and available to all users.

SYSTEM_THEMES = [
  {
    name: "Default Dark", variant: :dark,
    color_background:      "#0D1B2A",
    color_surface:         "#1B2F5B",
    color_surface_variant: "#162444",
    color_border:          "#2A4170",
    color_primary:         "#1B2F5B",
    color_accent:          "#00E5CC",
    color_text_primary:    "#FFFFFF",
    color_text_secondary:  "#A0B4CC",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#0D1B2A"
  },
  {
    name: "Default Light", variant: :light,
    color_background:      "#FFFFFF",
    color_surface:         "#F0F4F8",
    color_surface_variant: "#E2EAF4",
    color_border:          "#C8D6E8",
    color_primary:         "#1B2F5B",
    color_accent:          "#00B8A9",
    color_text_primary:    "#0D1B2A",
    color_text_secondary:  "#5A6E88",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#FFFFFF"
  },
  {
    name: "Pink Dark", variant: :dark,
    color_background:      "#1A0D12",
    color_surface:         "#2D1A20",
    color_surface_variant: "#3D1F28",
    color_border:          "#5C2D3A",
    color_primary:         "#8B1A4A",
    color_accent:          "#FF69B4",
    color_text_primary:    "#FFFFFF",
    color_text_secondary:  "#CCA0B0",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#1A0D12"
  },
  {
    name: "Pink Light", variant: :light,
    color_background:      "#FFF0F5",
    color_surface:         "#FFE4EE",
    color_surface_variant: "#FFD6E7",
    color_border:          "#F4A7C3",
    color_primary:         "#8B1A4A",
    color_accent:          "#D63384",
    color_text_primary:    "#2D0A18",
    color_text_secondary:  "#7A3A52",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#FFFFFF"
  },
  {
    name: "Green Dark", variant: :dark,
    color_background:      "#0D1A12",
    color_surface:         "#1A2E1E",
    color_surface_variant: "#1F3A24",
    color_border:          "#2D5535",
    color_primary:         "#1A4A2E",
    color_accent:          "#4ADE80",
    color_text_primary:    "#FFFFFF",
    color_text_secondary:  "#90C4A0",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#0D1A12"
  },
  {
    name: "Green Light", variant: :light,
    color_background:      "#F0FFF4",
    color_surface:         "#DCFCE7",
    color_surface_variant: "#C8F5D5",
    color_border:          "#86EFAC",
    color_primary:         "#1A4A2E",
    color_accent:          "#16A34A",
    color_text_primary:    "#0A2014",
    color_text_secondary:  "#3A6E4A",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#FFFFFF"
  },
  {
    name: "Blue Dark", variant: :dark,
    color_background:      "#0D1520",
    color_surface:         "#1E2D44",
    color_surface_variant: "#243552",
    color_border:          "#334D70",
    color_primary:         "#1E3A5F",
    color_accent:          "#60A5FA",
    color_text_primary:    "#FFFFFF",
    color_text_secondary:  "#93B4D4",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#0D1520"
  },
  {
    name: "Blue Light", variant: :light,
    color_background:      "#EFF6FF",
    color_surface:         "#DBEAFE",
    color_surface_variant: "#BFDBFE",
    color_border:          "#93C5FD",
    color_primary:         "#1E3A5F",
    color_accent:          "#2563EB",
    color_text_primary:    "#0A1A30",
    color_text_secondary:  "#3A5A80",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#FFFFFF"
  },
  {
    name: "Purple Dark", variant: :dark,
    color_background:      "#1A0D2E",
    color_surface:         "#2D1B4E",
    color_surface_variant: "#38225E",
    color_border:          "#5B3A8A",
    color_primary:         "#4C1D95",
    color_accent:          "#A78BFA",
    color_text_primary:    "#FFFFFF",
    color_text_secondary:  "#B8A0D4",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#1A0D2E"
  },
  {
    name: "Purple Light", variant: :light,
    color_background:      "#FAF5FF",
    color_surface:         "#EDE9FE",
    color_surface_variant: "#DDD6FE",
    color_border:          "#C4B5FD",
    color_primary:         "#4C1D95",
    color_accent:          "#7C3AED",
    color_text_primary:    "#1A0A30",
    color_text_secondary:  "#5B3A80",
    color_text_on_primary: "#FFFFFF",
    color_text_on_accent:  "#FFFFFF"
  }
].freeze

SYSTEM_THEMES.each do |attrs|
  Theme.find_or_create_by!(name: attrs[:name], scope: :system) do |t|
    t.variant               = attrs[:variant]
    t.color_background      = attrs[:color_background]
    t.color_surface         = attrs[:color_surface]
    t.color_surface_variant = attrs[:color_surface_variant]
    t.color_border          = attrs[:color_border]
    t.color_primary         = attrs[:color_primary]
    t.color_accent          = attrs[:color_accent]
    t.color_text_primary    = attrs[:color_text_primary]
    t.color_text_secondary  = attrs[:color_text_secondary]
    t.color_text_on_primary = attrs[:color_text_on_primary]
    t.color_text_on_accent  = attrs[:color_text_on_accent]
  end
end

# ── Users ─────────────────────────────────────────────────────────────────────

district_admin = User.find_or_create_by!(email: "admin@hsd.edu") do |u|
  u.first_name = "Sandra"
  u.last_name  = "Okafor"
  u.password   = "password123"
end

ahs_school_admin = User.find_or_create_by!(email: "schooladmin@ahs.edu") do |u|
  u.first_name = "Dana"
  u.last_name  = "Marsh"
  u.password   = "password123"
end

super_admin = User.find_or_create_by!(email: "superadmin@keepup.app") do |u|
  u.first_name = "Olivia"
  u.last_name  = "Koster"
  u.password   = "password123"
end

swim_commissioner = User.find_or_create_by!(email: "jeff.swim@kingcounty.gov") do |u|
  u.first_name = "Jeff"
  u.last_name  = "Harmon"
  u.password   = "password123"
end

ahs_ad = User.find_or_create_by!(email: "ad@ahs.edu") do |u|
  u.first_name = "Mike"
  u.last_name  = "Torres"
  u.password   = "password123"
end

bhs_ad = User.find_or_create_by!(email: "ad@bhs.edu") do |u|
  u.first_name = "Rachel"
  u.last_name  = "Kim"
  u.password   = "password123"
end

head_coach = User.find_or_create_by!(email: "coach.swim@ahs.edu") do |u|
  u.first_name = "Chris"
  u.last_name  = "Nguyen"
  u.password   = "password123"
end

asst_coach = User.find_or_create_by!(email: "asst.swim@ahs.edu") do |u|
  u.first_name = "Dana"
  u.last_name  = "Patel"
  u.password   = "password123"
end

student_captain = User.find_or_create_by!(email: "captain@ahs.student.edu") do |u|
  u.first_name = "Alex"
  u.last_name  = "Rivera"
  u.password   = "password123"
end

student_1 = User.find_or_create_by!(email: "student1@ahs.student.edu") do |u|
  u.first_name = "Jordan"
  u.last_name  = "Lee"
  u.password   = "password123"
end

student_2 = User.find_or_create_by!(email: "student2@bhs.student.edu") do |u|
  u.first_name = "Taylor"
  u.last_name  = "Brooks"
  u.password   = "password123"
end

polo_coach = User.find_or_create_by!(email: "coach.polo@ahs.edu") do |u|
  u.first_name = "Sam"
  u.last_name  = "Rivera"
  u.password   = "password123"
end

student_3 = User.find_or_create_by!(email: "student3@ahs.student.edu") do |u|
  u.first_name = "Casey"
  u.last_name  = "Lee"
  u.password   = "password123"
end

parent_1 = User.find_or_create_by!(email: "parent1@example.com") do |u|
  u.first_name         = "Morgan"
  u.last_name          = "Lee"
  u.password           = "password123"
  u.preferred_language = "es"
end

captain_parent = User.find_or_create_by!(email: "captain_parent@example.com") do |u|
  u.first_name = "Lisa"
  u.last_name  = "Rivera"
  u.password   = "password123"
end

# ── Institution Roles ─────────────────────────────────────────────────────────

InstitutionRole.find_or_create_by!(user: super_admin,      role: :super_admin)
InstitutionRole.find_or_create_by!(user: district_admin,   role: :district_admin,   district: hsd)
InstitutionRole.find_or_create_by!(user: ahs_school_admin, role: :school_admin,     school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_ad,           role: :athletic_director, school: ahs)
InstitutionRole.find_or_create_by!(user: bhs_ad,           role: :athletic_director, school: bhs)
InstitutionRole.find_or_create_by!(user: head_coach,       role: :head_coach,       school: ahs)
InstitutionRole.find_or_create_by!(user: asst_coach,       role: :assistant_coach,  school: ahs)

# ── School Themes ─────────────────────────────────────────────────────────────
# ADs can set exactly one dark + one light theme for their school.
# AHS example: navy + gold (Hawks school colors)

# AHS Hawks — navy + gold school colors
Theme.find_or_create_by!(scope: :school, school: ahs, variant: :dark) do |t|
  t.name                  = "Hawks Dark"
  t.created_by            = ahs_ad
  t.color_background      = "#0D1520"
  t.color_surface         = "#1B2840"
  t.color_surface_variant = "#1F3050"
  t.color_border          = "#2E4470"
  t.color_primary         = "#1B2F5B"
  t.color_accent          = "#FFD700"
  t.color_text_primary    = "#FFFFFF"
  t.color_text_secondary  = "#A0AACC"
  t.color_text_on_primary = "#FFD700"
  t.color_text_on_accent  = "#0D1520"
end

Theme.find_or_create_by!(scope: :school, school: ahs, variant: :light) do |t|
  t.name                  = "Hawks Light"
  t.created_by            = ahs_ad
  t.color_background      = "#FFFEF0"
  t.color_surface         = "#FFF9C4"
  t.color_surface_variant = "#FFF3A0"
  t.color_border          = "#E8D060"
  t.color_primary         = "#1B2F5B"
  t.color_accent          = "#B8860B"
  t.color_text_primary    = "#0D1520"
  t.color_text_secondary  = "#4A5A7A"
  t.color_text_on_primary = "#FFD700"
  t.color_text_on_accent  = "#FFFFFF"
end

# ── Sport Templates (district-managed catalog) ────────────────────────────────
# District admin sets which sports exist, what season they run, and whether
# boys/girls compete separately or as a combined program.

swim_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Swimming")
swim_template.assign_attributes(athletic_season: :winter, gender_config: :separate, active: true)
swim_template.save!

basket_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Basketball")
basket_template.assign_attributes(athletic_season: :winter, gender_config: :separate, active: true)
basket_template.save!

polo_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Water Polo")
polo_template.assign_attributes(athletic_season: :fall, gender_config: :separate, active: true)
polo_template.save!

soccer_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Soccer")
soccer_template.assign_attributes(athletic_season: :fall, gender_config: :separate, active: true)
soccer_template.save!

tf_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Track & Field")
tf_template.assign_attributes(athletic_season: :spring, gender_config: :combined, active: true)
tf_template.save!

# ── Sport Commissionerships ───────────────────────────────────────────────────
# Jeff oversees swimming for the entire HSD district — assigned by Sophia (super admin).

SportCommissionership.find_or_create_by!(user: swim_commissioner, sport_template: swim_template, district: hsd) do |sc|
  sc.status      = :active
  sc.assigned_by = super_admin
  sc.assigned_at = 1.month.ago
end

# ── Sports (school-level programs) ────────────────────────────────────────────
# Each Sport links a school to a template and specifies gender.
# Name is derived: "Girls Swimming", "Boys Water Polo", etc.

swimming = Sport.find_or_create_by!(sport_template: swim_template, school: ahs, gender: :girls) do |s|
  s.sport_type = "swimming"
  s.status     = :pending
end

# ── Additional users (coaches for new sports) ─────────────────────────────────

ahs_basketball_coach = User.find_or_create_by!(email: "coach.bball@ahs.edu") do |u|
  u.first_name = "Marcus"
  u.last_name  = "Webb"
  u.password   = "password123"
end

ahs_basketball_asst = User.find_or_create_by!(email: "asst.bball@ahs.edu") do |u|
  u.first_name = "Tyra"
  u.last_name  = "Holland"
  u.password   = "password123"
end

ahs_soccer_coach = User.find_or_create_by!(email: "coach.soccer@ahs.edu") do |u|
  u.first_name = "Lena"
  u.last_name  = "Morales"
  u.password   = "password123"
end

ahs_tf_coach = User.find_or_create_by!(email: "coach.tf@ahs.edu") do |u|
  u.first_name = "Devin"
  u.last_name  = "Santos"
  u.password   = "password123"
end

ahs_tf_asst = User.find_or_create_by!(email: "asst.tf@ahs.edu") do |u|
  u.first_name = "Nia"
  u.last_name  = "Foster"
  u.password   = "password123"
end

bhs_basketball_coach = User.find_or_create_by!(email: "coach.bball@bhs.edu") do |u|
  u.first_name = "Tony"
  u.last_name  = "Rivera"
  u.password   = "password123"
end

bhs_girls_swim_coach = User.find_or_create_by!(email: "coach.girlsswim@bhs.edu") do |u|
  u.first_name = "Rachel"
  u.last_name  = "Park"
  u.password   = "password123"
end

chs_ad = User.find_or_create_by!(email: "ad@chs.edu") do |u|
  u.first_name = "Luis"
  u.last_name  = "Ortega"
  u.password   = "password123"
end

chs_swim_coach = User.find_or_create_by!(email: "coach.swim@chs.edu") do |u|
  u.first_name = "Diana"
  u.last_name  = "Walsh"
  u.password   = "password123"
end

chs = School.find_or_create_by!(name: "Crest High School", district: hsd) do |s|
  s.city   = "Riverside"
  s.state  = "WA"
  s.active = true
end

InstitutionRole.find_or_create_by!(user: chs_ad, role: :athletic_director, school: chs)
InstitutionRole.find_or_create_by!(user: ahs_basketball_coach, role: :head_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_soccer_coach, role: :head_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_tf_coach, role: :head_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: bhs_basketball_coach, role: :head_coach, school: bhs)
InstitutionRole.find_or_create_by!(user: bhs_girls_swim_coach, role: :head_coach, school: bhs)
InstitutionRole.find_or_create_by!(user: chs_swim_coach, role: :head_coach, school: chs)

# BHS Boys Swimming — Chris Nguyen is assistant coach here (same Hajos district)
bhs_boys_swimming = Sport.find_or_create_by!(sport_template: swim_template, school: bhs, gender: :boys) do |s|
  s.sport_type = "swimming"
  s.status     = :active
end

water_polo = Sport.find_or_create_by!(sport_template: polo_template, school: ahs, gender: :boys) do |s|
  s.sport_type = "water_polo"
  s.status     = :active
end

# ── AHS additional sports ─────────────────────────────────────────────────────

ahs_boys_basketball = Sport.find_or_create_by!(sport_template: basket_template, school: ahs, gender: :boys) do |s|
  s.status = :active
end

ahs_girls_soccer = Sport.find_or_create_by!(sport_template: soccer_template, school: ahs, gender: :girls) do |s|
  s.status = :inactive
end

ahs_tf = Sport.find_or_create_by!(sport_template: tf_template, school: ahs, gender: :coed) do |s|
  s.status = :pending
end

# ── BHS additional sports ─────────────────────────────────────────────────────

bhs_girls_swimming = Sport.find_or_create_by!(sport_template: swim_template, school: bhs, gender: :girls) do |s|
  s.status = :active
end

bhs_boys_basketball = Sport.find_or_create_by!(sport_template: basket_template, school: bhs, gender: :boys) do |s|
  s.status = :active
end

# ── CHS sports ────────────────────────────────────────────────────────────────

chs_girls_swimming = Sport.find_or_create_by!(sport_template: swim_template, school: chs, gender: :girls) do |s|
  s.status = :active
end


# ── Co-op Authorizations (swimming is shared with BHS) ───────────────────────

ahs_auth = CoopAuthorization.find_or_create_by!(sport: swimming, school: ahs) do |ca|
  ca.athletic_director = ahs_ad
  ca.status            = :approved
  ca.approved_at       = 1.week.ago
end

bhs_auth = CoopAuthorization.find_or_create_by!(sport: swimming, school: bhs) do |ca|
  ca.athletic_director = bhs_ad
  ca.status            = :approved
  ca.approved_at       = 1.week.ago
end

swimming.activate_if_ready!

# ── Seasons ───────────────────────────────────────────────────────────────────
# One season per sport per school year. Athlete level (varsity/JV/etc.) lives on SeasonMembership.

swim_season = Season.find_or_create_by!(sport: swimming, school_year: "2025-26") do |s|
  s.sport     = swimming
  s.name      = "Swimming 2025-26"
  s.starts_at = Date.new(2025, 8, 18)
  s.ends_at   = Date.new(2025, 11, 15)
  s.status    = :active
end

bhs_swim_coach = User.find_or_create_by!(email: "coach.swim@bhs.edu") do |u|
  u.first_name = "Tony"
  u.last_name  = "Kim"
  u.password   = "password123"
end

bhs_swim_student_1 = User.find_or_create_by!(email: "marcus.tran@bhs.student.edu") do |u|
  u.first_name = "Marcus"
  u.last_name  = "Tran"
  u.password   = "password123"
end

bhs_swim_student_2 = User.find_or_create_by!(email: "leo.svensson@bhs.student.edu") do |u|
  u.first_name = "Leo"
  u.last_name  = "Svensson"
  u.password   = "password123"
end

bhs_swim_season = Season.find_or_create_by!(sport: bhs_boys_swimming, school_year: "2025-26") do |s|
  s.sport     = bhs_boys_swimming
  s.name      = "Boys Swimming BHS 2025-26"
  s.starts_at = Date.new(2025, 8, 18)
  s.ends_at   = Date.new(2025, 11, 15)
  s.status    = :active
end

SeasonMembership.find_or_create_by!(user: bhs_swim_coach, season: bhs_swim_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: head_coach,     season: bhs_swim_season) { |sm| sm.role = :assistant_coach }
SeasonMembership.find_or_create_by!(user: bhs_swim_student_1, season: bhs_swim_season) { |sm| sm.role = :student; sm.is_captain = true }
SeasonMembership.find_or_create_by!(user: bhs_swim_student_2, season: bhs_swim_season) { |sm| sm.role = :student }

polo_season = Season.find_or_create_by!(sport: water_polo, school_year: "2025-26") do |s|
  s.sport     = water_polo
  s.name      = "Water Polo 2025-26"
  s.starts_at = Date.new(2026, 3, 2)
  s.ends_at   = Date.new(2026, 5, 30)
  s.status    = :active
end

# ── Season Memberships ────────────────────────────────────────────────────────

SeasonMembership.find_or_create_by!(user: head_coach,      season: swim_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: asst_coach,      season: swim_season) { |sm| sm.role = :assistant_coach }
SeasonMembership.find_or_create_by!(user: student_captain, season: swim_season) { |sm| sm.role = :student; sm.is_captain = true }
SeasonMembership.find_or_create_by!(user: student_1,       season: swim_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: student_2,       season: swim_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: parent_1,        season: swim_season) { |sm| sm.role = :parent }
SeasonMembership.find_or_create_by!(user: captain_parent,  season: swim_season) { |sm| sm.role = :parent }

# Chris Nguyen (head_coach) is head coach of Water Polo in addition to Girls Swimming
# polo_coach (Kevin Park) assists
SeasonMembership.find_or_create_by!(user: head_coach, season: polo_season) { |sm| sm.role = :head_coach }

polo_asst_sm = SeasonMembership.find_or_create_by!(user: polo_coach, season: polo_season) { |sm| sm.role = :assistant_coach }
polo_asst_sm.update!(role: :assistant_coach) unless polo_asst_sm.assistant_coach?

# Water polo students
polo_student_1 = User.find_or_create_by!(email: "polo1@ahs.student.edu") do |u|
  u.first_name = "Mateo"; u.last_name = "Rivera"; u.password = "password123"
end
polo_student_2 = User.find_or_create_by!(email: "polo2@ahs.student.edu") do |u|
  u.first_name = "Aiden"; u.last_name = "Cheng"; u.password = "password123"
end
polo_student_3 = User.find_or_create_by!(email: "polo3@ahs.student.edu") do |u|
  u.first_name = "Eli"; u.last_name = "Nakamura"; u.password = "password123"
end
polo_student_4 = User.find_or_create_by!(email: "polo4@ahs.student.edu") do |u|
  u.first_name = "Sam"; u.last_name = "Okonkwo"; u.password = "password123"
end
polo_parent_2 = User.find_or_create_by!(email: "parent2@example.com") do |u|
  u.first_name = "Diane"; u.last_name = "Rivera"; u.password = "password123"
end

SeasonMembership.find_or_create_by!(user: student_3,      season: polo_season) { |sm| sm.role = :student; sm.is_captain = true }
SeasonMembership.find_or_create_by!(user: polo_student_1,  season: polo_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: polo_student_2,  season: polo_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: polo_student_3,  season: polo_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: polo_student_4,  season: polo_season) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: parent_1,        season: polo_season) { |sm| sm.role = :parent }
SeasonMembership.find_or_create_by!(user: polo_parent_2,   season: polo_season) { |sm| sm.role = :parent }

# Water polo channels
polo_general = Channel.find_or_create_by!(season: polo_season, name: "general") do |c|
  c.created_by = head_coach; c.channel_type = :conversation; c.system_generated = true
end
polo_announcements = Channel.find_or_create_by!(season: polo_season, name: "announcements") do |c|
  c.created_by = head_coach; c.channel_type = :broadcast; c.system_generated = true
end

[ polo_general, polo_announcements ].each do |ch|
  [ head_coach, polo_coach, student_3, polo_student_1, polo_student_2, polo_student_3, polo_student_4, parent_1, polo_parent_2 ].each do |u|
    ChannelMembership.find_or_create_by!(channel: ch, user: u)
  end
end

Message.find_or_create_by!(channel: polo_announcements, sender: head_coach,
  content: "Welcome to Boys Water Polo 2025-26! First practice is March 4 at the AHS Aquatic Center, 3:30pm. Caps and suits required.")
Message.find_or_create_by!(channel: polo_general, sender: student_3,
  content: "Can't wait — who's been working on their eggbeater kick over break?")
Message.find_or_create_by!(channel: polo_general, sender: polo_student_1,
  content: "Been in the water every week. Feel good going into the season.")
Message.find_or_create_by!(channel: polo_general, sender: head_coach,
  content: "Good energy. We'll open with conditioning sets. Come ready to work.")

# ── New sport seasons + memberships ──────────────────────────────────────────

ahs_bball_season = Season.find_or_create_by!(sport: ahs_boys_basketball, school_year: "2025-26") do |s|
  s.sport     = ahs_boys_basketball
  s.name      = "Boys Basketball AHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 3, 15)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: ahs_basketball_coach, season: ahs_bball_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ahs_basketball_asst,  season: ahs_bball_season) { |sm| sm.role = :assistant_coach }

ahs_soccer_season = Season.find_or_create_by!(sport: ahs_girls_soccer, school_year: "2025-26") do |s|
  s.sport     = ahs_girls_soccer
  s.name      = "Girls Soccer AHS 2025-26"
  s.starts_at = Date.new(2025, 8, 25)
  s.ends_at   = Date.new(2025, 11, 1)
  s.status    = :archived
end
SeasonMembership.find_or_create_by!(user: ahs_soccer_coach, season: ahs_soccer_season) { |sm| sm.role = :head_coach }

ahs_tf_season = Season.find_or_create_by!(sport: ahs_tf, school_year: "2025-26") do |s|
  s.sport     = ahs_tf
  s.name      = "Track & Field AHS 2025-26"
  s.starts_at = Date.new(2026, 3, 1)
  s.ends_at   = Date.new(2026, 6, 1)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: ahs_tf_coach, season: ahs_tf_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ahs_tf_asst,  season: ahs_tf_season) { |sm| sm.role = :assistant_coach }

bhs_girls_swim_season = Season.find_or_create_by!(sport: bhs_girls_swimming, school_year: "2025-26") do |s|
  s.sport     = bhs_girls_swimming
  s.name      = "Girls Swimming BHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 2, 28)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: bhs_girls_swim_coach, season: bhs_girls_swim_season) { |sm| sm.role = :head_coach }

bhs_bball_season = Season.find_or_create_by!(sport: bhs_boys_basketball, school_year: "2025-26") do |s|
  s.sport     = bhs_boys_basketball
  s.name      = "Boys Basketball BHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 3, 15)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: bhs_basketball_coach, season: bhs_bball_season) { |sm| sm.role = :head_coach }

chs_swim_season = Season.find_or_create_by!(sport: chs_girls_swimming, school_year: "2025-26") do |s|
  s.sport     = chs_girls_swimming
  s.name      = "Girls Swimming CHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 2, 28)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: chs_swim_coach, season: chs_swim_season) { |sm| sm.role = :head_coach }

# ── Parent-Student Relationship ───────────────────────────────────────────────

ParentStudentRelationship.find_or_create_by!(parent: parent_1,       student: student_1)
ParentStudentRelationship.find_or_create_by!(parent: parent_1,       student: student_3)
ParentStudentRelationship.find_or_create_by!(parent: captain_parent, student: student_captain)

# ── Default Channels ──────────────────────────────────────────────────────────

general = Channel.find_or_create_by!(season: swim_season, name: "general") do |c|
  c.created_by       = head_coach
  c.channel_type     = :conversation
  c.system_generated = true
end

announcements = Channel.find_or_create_by!(season: swim_season, name: "announcements") do |c|
  c.created_by       = head_coach
  c.channel_type     = :broadcast
  c.system_generated = true
end

athletes_only = Channel.find_or_create_by!(season: swim_season, name: "athletes-only") do |c|
  c.created_by       = head_coach
  c.channel_type     = :athletes_only
  c.system_generated = true
end

# ── Channel Memberships ───────────────────────────────────────────────────────

[ general, announcements ].each do |channel|
  [ head_coach, asst_coach, student_captain, student_1, student_2, parent_1 ].each do |user|
    ChannelMembership.find_or_create_by!(channel: channel, user: user)
  end
end

[ athletes_only ].each do |channel|
  [ student_captain, student_1, student_2 ].each do |user|
    ChannelMembership.find_or_create_by!(channel: channel, user: user)
  end
end

# ── Announcements channel ─────────────────────────────────────────────────────

msg_welcome = Message.find_or_create_by!(channel: announcements, sender: head_coach,
  content: "Welcome to the 2025-26 swim season! First practice is Monday at 6am. Bring your own cap and goggles.") do |m|
  m.pinned_at  = 2.weeks.ago
  m.pinned_by  = head_coach
end

Message.find_or_create_by!(channel: announcements, sender: head_coach,
  content: "Reminder: all athletes need updated physical forms submitted to the front office before Friday. No form = no practice.")

Message.find_or_create_by!(channel: announcements, sender: asst_coach,
  content: "Meet schedule for November is posted on the school athletics page. First away meet is Nov 14 @ Baldwin — bus departs at 3:30pm sharp.")

# ── General channel ───────────────────────────────────────────────────────────

msg_general_1 = Message.find_or_create_by!(channel: general, sender: student_captain,
  content: "Can't wait — see everyone Monday! Who's been training over the summer?")

msg_general_2 = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "Been doing open water swims at Riverside Lake. Feeling ready 🌊")

Message.find_or_create_by!(channel: general, sender: student_2,
  content: "Same! Anyone need a ride Monday? I have room for 2 more from the BHS side.")

Message.find_or_create_by!(channel: general, sender: asst_coach,
  content: "Love the energy. See you all at 6am — don't be late, we're starting dry-land immediately.")

Message.find_or_create_by!(channel: general, sender: student_captain,
  content: "Coach Nguyen, are we doing time trials first week or just base training?")

Message.find_or_create_by!(channel: general, sender: head_coach,
  content: "Time trials Thursday. Get some rest Tuesday and Wednesday.")

# ── Questionable message — held, ⚠️ visible to Jordan (student_1) ─────────────
# Gemma scored this 0.52 — borderline trash talk before a meet.
# Delivers to the channel; coach sees a review notification (Gemma training only).

msg_questionable = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "Baldwin better watch out, I'm going to absolutely destroy their relays 😤") do |m|
  m.flagged          = true
  m.moderation_score = 0.52
  m.flag_reason      = "Potentially aggressive language targeting another school's athletes"
  m.flag_action      = "held"
end

# ── Severe message — blocked, 🚫 visible only to Jordan ──────────────────────
# Gemma scored this 0.92. Blocked entirely. Coach + AD notified.

msg_severe = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "I'm going to kill Coach if he benches me one more time") do |m|
  m.flagged          = true
  m.moderation_score = 0.92
  m.flag_reason      = "Direct threat toward a named person"
  m.flag_action      = "blocked"
end

MessageChallenge.create!(
  message:    msg_severe,
  challenger: student_1,
  reason:     "I was just frustrated and venting — I would never actually hurt anyone. Please don't block me.",
)

# ── Athletes-only channel ─────────────────────────────────────────────────────

Message.find_or_create_by!(channel: athletes_only, sender: student_captain,
  content: "Team meeting after practice Wednesday — just athletes, captains have an agenda item to cover.")

Message.find_or_create_by!(channel: athletes_only, sender: student_2,
  content: "Are parents invited? Mine keeps asking about the banquet planning.")

Message.find_or_create_by!(channel: athletes_only, sender: student_captain,
  content: "No parents this one. Coaches set this channel up specifically so we have our own space.")

# ── Coaches-only channel ──────────────────────────────────────────────────────

coaches_only = Channel.find_or_create_by!(season: swim_season, name: "coaches") do |c|
  c.created_by       = head_coach
  c.channel_type     = :coaches_only
  c.system_generated = true
end

ChannelMembership.find_or_create_by!(channel: coaches_only, user: head_coach)
ChannelMembership.find_or_create_by!(channel: coaches_only, user: asst_coach)

Message.find_or_create_by!(channel: coaches_only, sender: head_coach,
  content: "Dana — I flagged Jordan's message in general for review. Can you keep an eye on that situation this week?")

Message.find_or_create_by!(channel: coaches_only, sender: asst_coach,
  content: "On it. I think there's some tension between Jordan and a few of the BHS kids. Will check in before Wednesday.")

# ── Reactions ─────────────────────────────────────────────────────────────────

Reaction.find_or_create_by!(message: msg_welcome,   user: student_captain, emoji: "🔥")
Reaction.find_or_create_by!(message: msg_welcome,   user: student_1,       emoji: "👍")
Reaction.find_or_create_by!(message: msg_general_1, user: student_1,       emoji: "👍")
Reaction.find_or_create_by!(message: msg_general_2, user: student_captain, emoji: "🌊")
Reaction.find_or_create_by!(message: msg_general_2, user: student_2,       emoji: "❤️")

# ── DM Conversations ──────────────────────────────────────────────────────────

# Coach ↔ Captain
dm_coach_captain = DmConversation.between(head_coach, student_captain, swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: head_coach,
  content: "Hey Alex — great leadership at tryouts. I'm going to lean on you a lot this season.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: student_captain,
  content: "Thanks Coach. Quick question — should I be worried about Jordan? Seems a little on edge lately.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: head_coach,
  content: "I've noticed it too. Coach Patel and I are keeping an eye on it. Thanks for flagging.")

# Coach ↔ Student 1 (Jordan)
dm_coach_jordan = DmConversation.between(head_coach, student_1, swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: head_coach,
  content: "Jordan — checking in. How are you feeling about the season?")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: student_1,
  content: "Honestly kind of stressed. Trying to get my times down before Baldwin.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: head_coach,
  content: "That's normal. Let's talk after practice Wednesday — I have some thoughts on your pacing strategy.")

# Parent ↔ Coach
dm_parent_coach = DmConversation.between(parent_1, head_coach, swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_parent_coach, sender: parent_1,
  content: "Hi Coach Nguyen — Morgan here, Jordan's parent. Just wanted to introduce myself and say thank you for the welcome message.")
DirectMessage.find_or_create_by!(dm_conversation: dm_parent_coach, sender: head_coach,
  content: "Hi Morgan, great to meet you. Jordan has a lot of potential — excited to work with them this season.")

# Student ↔ Student (visible to parent — other party shown as "Student")
dm_jordan_student2 = DmConversation.between(student_1, student_2, swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_student2, sender: student_2,
  content: "You going to the dual meet Saturday?")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_student2, sender: student_1,
  content: "Yeah, Coach said bus leaves at 7. You need a ride to school?")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_student2, sender: student_2,
  content: "That'd be great, let me check with my mom")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_student2, sender: student_1,
  content: "No worries, just let me know by Thursday")

# ── Family Group Chat ─────────────────────────────────────────────────────────
# Parent-created group for carpool coordination. Both students must have their
# parent in the group (enforced by the family_groups controller).

carpool_group = Channel.find_or_create_by!(season: swim_season, name: "Carpool Crew") do |c|
  c.created_by       = parent_1
  c.channel_type     = :family_group
  c.system_generated = false
  c.active           = true
end

[ parent_1, captain_parent, student_1, student_captain ].each do |user|
  ChannelMembership.find_or_create_by!(channel: carpool_group, user: user)
end

Message.find_or_create_by!(channel: carpool_group, sender: parent_1,
  content: "Hi everyone! Setting up this group so we can coordinate rides to meets and practices 🏊")
Message.find_or_create_by!(channel: carpool_group, sender: captain_parent,
  content: "Perfect idea Morgan! Alex has the Baldwin Invitational on the 3rd — happy to drive both times if you can take the State qualifier.")
Message.find_or_create_by!(channel: carpool_group, sender: parent_1,
  content: "Deal! I'll handle State. Jordan, can you confirm your event schedule so Lisa and I can plan around it?")
Message.find_or_create_by!(channel: carpool_group, sender: student_1,
  content: "I swim the 200 free and 4x100 relay both days. Events usually start at 9.")
Message.find_or_create_by!(channel: carpool_group, sender: student_captain,
  content: "Same for me. Thanks for doing this — way easier than the group chat chaos last year 😂")

# ── Parent View Requests ───────────────────────────────────────────────────────
# Pre-seed a pending request so the AD dashboard has something to act on in demos.
ParentViewRequest.create!(
  parent: parent_1,
  child:  student_1,
  reason: "Jordan has seemed stressed lately and mentioned something happened at practice. I just want to make sure everything is okay.",
  status: :pending,
)

# ── Moderation Notifications ──────────────────────────────────────────────────
# These surface in the coach and AD review dashboards.

# Coach sees the questionable message for review
ModerationNotification.find_or_create_by!(
  recipient: head_coach,
  message: msg_questionable,
  notification_type: :questionable_review,
  recipient_role: :head_coach
)

# Coach + AD both see the severe blocked message
ModerationNotification.find_or_create_by!(
  recipient: head_coach,
  message: msg_severe,
  notification_type: :severe_alert,
  recipient_role: :head_coach
)

ModerationNotification.find_or_create_by!(
  recipient: ahs_ad,
  message: msg_severe,
  notification_type: :severe_alert,
  recipient_role: :athletic_director
)

# ── Activity Feed Records ─────────────────────────────────────────────────────
# Message activities are normally written by ModerationNotificationJob (async).
# We create them directly here so the demo feed is populated on first seed.

Activity.find_or_create_by!(subject_type: "Message", subject_id: msg_questionable.id) do |a|
  a.event_type  = :message_flagged
  a.actor       = student_1
  a.season      = swim_season
  a.school      = ahs
  a.occurred_at = 2.days.ago
  a.metadata    = {
    tier:        "questionable",
    flag_action: "held",
    flag_reason: msg_questionable.flag_reason,
    sport:       swimming.name,
    season:      swim_season.name,
    channel:     general.name
  }
end

Activity.find_or_create_by!(subject_type: "Message", subject_id: msg_severe.id) do |a|
  a.event_type  = :message_flagged
  a.actor       = student_1
  a.season      = swim_season
  a.school      = ahs
  a.occurred_at = 1.day.ago
  a.metadata    = {
    tier:        "severe",
    flag_action: "blocked",
    flag_reason: msg_severe.flag_reason,
    sport:       swimming.name,
    season:      swim_season.name,
    channel:     general.name
  }
end

# ── Calendar Events ───────────────────────────────────────────────────────────

CalendarEvent.find_or_create_by!(sport: swimming, title: "vs Baldwin High School", starts_at: Date.new(2026, 5, 14).to_time) do |e|
  e.created_by = head_coach; e.event_type = :meet; e.home_away = :home; e.location = "AHS Aquatic Center"
  e.opponent = "Baldwin High School"; e.ends_at = Date.new(2026, 5, 14).to_time + 3.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: swimming, title: "KingCo Championships — Prelims", starts_at: Date.new(2026, 5, 20).to_time) do |e|
  e.created_by = head_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "King County Aquatic Center"
  e.ends_at = Date.new(2026, 5, 20).to_time + 10.hours; e.status = :scheduled
  e.notes = "All 16 KingCo schools competing. Check in no later than 7:30 AM."
end
CalendarEvent.find_or_create_by!(sport: swimming, title: "vs Eastlake High School", starts_at: Date.new(2026, 5, 27).to_time) do |e|
  e.created_by = head_coach; e.event_type = :meet; e.home_away = :away; e.location = "Eastlake Aquatic Center"
  e.opponent = "Eastlake High School"; e.ends_at = Date.new(2026, 5, 27).to_time + 3.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: swimming, title: "KingCo Championships — Finals", starts_at: Date.new(2026, 6, 3).to_time) do |e|
  e.created_by = head_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "King County Aquatic Center"
  e.ends_at = Date.new(2026, 6, 3).to_time + 11.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: swimming, title: "End of Season Banquet", starts_at: Date.new(2026, 6, 10).to_time + 18.hours) do |e|
  e.created_by = head_coach; e.event_type = :other; e.home_away = :home; e.location = "AHS Cafeteria"
  e.ends_at = Date.new(2026, 6, 10).to_time + 21.hours; e.status = :scheduled
  e.notes = "Awards and recognition. Athletes bring a guest."
end

CalendarEvent.find_or_create_by!(sport: bhs_boys_swimming, title: "vs Alfred High School", starts_at: Date.new(2026, 5, 16).to_time + 14.hours) do |e|
  e.created_by = head_coach; e.event_type = :meet; e.home_away = :home; e.location = "BHS Natatorium"
  e.opponent = "Alfred High School"; e.ends_at = Date.new(2026, 5, 16).to_time + 17.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: bhs_boys_swimming, title: "KingCo Championships — Prelims", starts_at: Date.new(2026, 5, 20).to_time) do |e|
  e.created_by = head_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "King County Aquatic Center"
  e.ends_at = Date.new(2026, 5, 20).to_time + 10.hours; e.status = :scheduled
end

CalendarEvent.find_or_create_by!(sport: ahs_boys_basketball, title: "vs Crest High School", starts_at: Date.new(2026, 1, 15).to_time + 19.hours) do |e|
  e.created_by = head_coach; e.event_type = :game; e.home_away = :home; e.location = "AHS Gymnasium"
  e.opponent = "Crest High School"; e.ends_at = Date.new(2026, 1, 15).to_time + 21.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: ahs_boys_basketball, title: "vs Baldwin High School", starts_at: Date.new(2026, 1, 22).to_time + 19.hours) do |e|
  e.created_by = head_coach; e.event_type = :game; e.home_away = :away; e.location = "BHS Gymnasium"
  e.opponent = "Baldwin High School"; e.ends_at = Date.new(2026, 1, 22).to_time + 21.hours; e.status = :scheduled
end

# ── Water Polo calendar events ────────────────────────────────────────────────

CalendarEvent.find_or_create_by!(sport: water_polo, title: "vs Eastlake High School", starts_at: Date.new(2026, 5, 13).to_time + 15.hours) do |e|
  e.created_by = head_coach; e.event_type = :meet; e.home_away = :home; e.location = "AHS Aquatic Center"
  e.opponent = "Eastlake High School"; e.ends_at = Date.new(2026, 5, 13).to_time + 18.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: water_polo, title: "vs Baldwin High School", starts_at: Date.new(2026, 5, 20).to_time + 15.hours) do |e|
  e.created_by = head_coach; e.event_type = :meet; e.home_away = :away; e.location = "BHS Aquatic Center"
  e.opponent = "Baldwin High School"; e.ends_at = Date.new(2026, 5, 20).to_time + 18.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: water_polo, title: "KingCo Water Polo Tournament", starts_at: Date.new(2026, 5, 28).to_time + 9.hours) do |e|
  e.created_by = head_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "King County Aquatic Center"
  e.ends_at = Date.new(2026, 5, 28).to_time + 18.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: water_polo, title: "End of Season Banquet", starts_at: Date.new(2026, 6, 5).to_time + 18.hours) do |e|
  e.created_by = head_coach; e.event_type = :other; e.home_away = :home; e.location = "AHS Cafeteria"
  e.ends_at = Date.new(2026, 6, 5).to_time + 21.hours; e.status = :scheduled
end

# ── Access Logs — demonstrates audit trail + anomaly detection ────────────────
# Head coach accessed Jordan's DM history multiple times in a short window.
# The third access is anomaly-flagged by Gemma.

AccessLog.find_or_create_by!(accessor: head_coach, accessed_user: student_1,
  accessor_role: "head_coach", reason: :conduct_concern, resource_type: "DmConversation",
  resource_id: dm_coach_jordan.id, sport: swimming) do |log|
  log.created_at = 3.days.ago
end

AccessLog.find_or_create_by!(accessor: head_coach, accessed_user: student_1,
  accessor_role: "head_coach", reason: :safety_issue, resource_type: "DmConversation",
  resource_id: dm_coach_jordan.id, sport: swimming) do |log|
  log.created_at = 2.days.ago
end

anomalous_log = AccessLog.find_or_create_by!(accessor: head_coach, accessed_user: student_1,
  accessor_role: "head_coach", reason: :conduct_concern, resource_type: "DmConversation",
  resource_id: dm_coach_jordan.id, sport: swimming) do |log|
  log.created_at      = 1.day.ago
  log.anomaly_flagged = true
  log.anomaly_score   = 0.81
  log.anomaly_reason  = "Accessor has accessed this student's DM history 3 times in 72 hours with escalating stated reasons. Pattern suggests monitoring behaviour warranting review."
end

# ── Custom Sport Emojis ───────────────────────────────────────────────────────

# Pending — waiting for Gemma pre-screen + human approval
SportEmoji.find_or_create_by!(sport: swimming, name: ":swimmer:") do |e|
  e.requested_by = student_captain
  e.image_url    = "https://placehold.co/128x128/1B2F5B/00E5CC?text=🏊"
  e.status       = :pending
end

# Auto-rejected by Gemma — surfaces in student's submission history with reason
SportEmoji.find_or_create_by!(sport: swimming, name: ":splash_rage:") do |e|
  e.requested_by = student_1
  e.image_url    = "https://placehold.co/128x128/FF0000/FFFFFF?text=X"
  e.status       = :auto_rejected
end

# Approved — available for reactions
SportEmoji.find_or_create_by!(sport: swimming, name: ":hawk:") do |e|
  e.requested_by = student_captain
  e.image_url    = "https://placehold.co/128x128/1B2F5B/FFD700?text=🦅"
  e.status       = :approved
  e.reviewed_by  = head_coach
  e.reviewed_at  = 1.week.ago
end

# ── BHS / CHS School Admins ───────────────────────────────────────────────────

bhs_school_admin = User.find_or_create_by!(email: "schooladmin@bhs.edu") do |u|
  u.first_name = "Michelle"
  u.last_name  = "Chen"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: bhs_school_admin, role: :school_admin, school: bhs)

chs_school_admin = User.find_or_create_by!(email: "schooladmin@chs.edu") do |u|
  u.first_name = "Patricia"
  u.last_name  = "Wu"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: chs_school_admin, role: :school_admin, school: chs)

# Missing assistant coach institution roles
InstitutionRole.find_or_create_by!(user: ahs_basketball_asst, role: :assistant_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_tf_asst,         role: :assistant_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: polo_coach,          role: :assistant_coach, school: ahs)
InstitutionRole.find_or_create_by!(user: bhs_swim_coach,      role: :head_coach,      school: bhs)

# ── School Themes (BHS + CHS) ─────────────────────────────────────────────────

Theme.find_or_create_by!(scope: :school, school: bhs, variant: :dark) do |t|
  t.name = "Knights Dark"; t.created_by = bhs_ad
  t.color_background = "#1A0D0D"; t.color_surface = "#2D1515"; t.color_surface_variant = "#3D1A1A"
  t.color_border = "#6B2020"; t.color_primary = "#7B1A1A"; t.color_accent = "#C0C0C0"
  t.color_text_primary = "#FFFFFF"; t.color_text_secondary = "#C8A0A0"
  t.color_text_on_primary = "#FFFFFF"; t.color_text_on_accent = "#1A0D0D"
end
Theme.find_or_create_by!(scope: :school, school: bhs, variant: :light) do |t|
  t.name = "Knights Light"; t.created_by = bhs_ad
  t.color_background = "#FFF8F8"; t.color_surface = "#FFE8E8"; t.color_surface_variant = "#FFD8D8"
  t.color_border = "#E8A0A0"; t.color_primary = "#7B1A1A"; t.color_accent = "#8B0000"
  t.color_text_primary = "#1A0D0D"; t.color_text_secondary = "#6B3030"
  t.color_text_on_primary = "#FFFFFF"; t.color_text_on_accent = "#FFFFFF"
end
Theme.find_or_create_by!(scope: :school, school: chs, variant: :dark) do |t|
  t.name = "Eagles Dark"; t.created_by = chs_ad
  t.color_background = "#0D1A0D"; t.color_surface = "#1A2D1A"; t.color_surface_variant = "#1F3820"
  t.color_border = "#2D5535"; t.color_primary = "#1A4A2E"; t.color_accent = "#FFB700"
  t.color_text_primary = "#FFFFFF"; t.color_text_secondary = "#90C4A0"
  t.color_text_on_primary = "#FFFFFF"; t.color_text_on_accent = "#0D1A0D"
end
Theme.find_or_create_by!(scope: :school, school: chs, variant: :light) do |t|
  t.name = "Eagles Light"; t.created_by = chs_ad
  t.color_background = "#F8FFF0"; t.color_surface = "#E8FFD8"; t.color_surface_variant = "#D8F5C8"
  t.color_border = "#A0D890"; t.color_primary = "#1A4A2E"; t.color_accent = "#2E7D32"
  t.color_text_primary = "#0D1A0D"; t.color_text_secondary = "#3A6E4A"
  t.color_text_on_primary = "#FFFFFF"; t.color_text_on_accent = "#FFFFFF"
end

# ── Enrich existing swim memberships with roster data ─────────────────────────

{
  student_captain => { grade: "12", level: "varsity", position: "Butterfly", is_captain: true, dob: Date.new(2007, 3, 14) },
  student_1       => { grade: "11", level: "varsity", position: "Freestyle",  is_captain: false, dob: Date.new(2008, 7, 22) },
  student_2       => { grade: "11", level: "varsity", position: "Backstroke", is_captain: false, dob: Date.new(2008, 11, 5) }
}.each do |user, attrs|
  sm = SeasonMembership.find_by!(user: user, season: swim_season)
  sm.update_columns(grade: attrs[:grade], level: attrs[:level], position: attrs[:position], is_captain: attrs[:is_captain])
  user.update_columns(dob: attrs[:dob])
end

# ── AHS Girls Swim — additional varsity athletes ───────────────────────────────

swim_students_varsity = [
  { email: "emma.j@ahs.student.edu",  first: "Emma",   last: "Johansson", dob: Date.new(2007, 1, 30), grade: "12", position: "Backstroke" },
  { email: "priya.s@ahs.student.edu", first: "Priya",  last: "Sharma",    dob: Date.new(2008, 5, 12), grade: "11", position: "Butterfly"  },
  { email: "zoe.m@ahs.student.edu",   first: "Zoe",    last: "Martinez",  dob: Date.new(2009, 9,  3), grade: "10", position: "Freestyle"  },
  { email: "chloe.p@ahs.student.edu", first: "Chloe",  last: "Park",      dob: Date.new(2009, 2, 18), grade: "10", position: "Breaststroke" },
  { email: "maya.j@ahs.student.edu",  first: "Maya",   last: "Johnson",   dob: Date.new(2010, 6,  7), grade: "9",  position: "IM"          }
]

swim_students_varsity.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: swim_season) do |sm|
    sm.role = :student; sm.grade = attrs[:grade]; sm.level = "varsity"; sm.position = attrs[:position]
  end
end

# ── AHS Girls Swim — underclassmen / JV-level athletes ───────────────────────
# Same season, same channels. Varsity vs JV is tracked on SeasonMembership.level only.

swim_students_jv = [
  { email: "lily.c@ahs.student.edu",  first: "Lily",   last: "Chen",     dob: Date.new(2010, 4, 25), position: "Freestyle"    },
  { email: "sofia.r@ahs.student.edu", first: "Sofia",  last: "Reyes",    dob: Date.new(2010, 8,  9), position: "Backstroke"   },
  { email: "anna.k@ahs.student.edu",  first: "Anna",   last: "Kowalski", dob: Date.new(2009, 12, 1), position: "Breaststroke" },
  { email: "nadia.h@ahs.student.edu", first: "Nadia",  last: "Hassan",   dob: Date.new(2010, 3, 17), position: "Freestyle"    }
]

swim_students_jv.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: swim_season) do |sm|
    sm.role = :student; sm.grade = "9"; sm.level = "jv"; sm.position = attrs[:position]
  end
  [ general, announcements, athletes_only ].each { |ch| ChannelMembership.find_or_create_by!(channel: ch, user: u) }
end

lily = User.find_by!(email: "lily.c@ahs.student.edu")
Message.find_or_create_by!(channel: general, sender: lily,
  content: "Will we get a chance to move up to varsity mid-season if times improve?")
Message.find_or_create_by!(channel: general, sender: head_coach,
  content: "Absolutely — varsity slots are earned. Hit your times and we'll talk.")
Message.find_or_create_by!(channel: general, sender: asst_coach,
  content: "Excited for this group — lots of talent coming up from the middle school programs.")

# ── AHS Boys Basketball — full roster, channels, messages ────────────────────

bball_players = [
  { email: "isaiah.w@ahs.student.edu",  first: "Isaiah",  last: "Williams", dob: Date.new(2007, 2, 10), grade: "12", jersey: "23", pos: "PG" },
  { email: "desmond.c@ahs.student.edu", first: "Desmond", last: "Carter",   dob: Date.new(2007, 8, 29), grade: "12", jersey: "15", pos: "SG", captain: true },
  { email: "marcus.j@ahs.student.edu",  first: "Marcus",  last: "Johnson",  dob: Date.new(2008, 4,  5), grade: "11", jersey: "10", pos: "SF" },
  { email: "elijah.b@ahs.student.edu",  first: "Elijah",  last: "Brooks",   dob: Date.new(2008, 11, 19), grade: "11", jersey: "32", pos: "PF" },
  { email: "noah.g@ahs.student.edu",    first: "Noah",    last: "Garcia",   dob: Date.new(2008, 6, 14), grade: "11", jersey: "5",  pos: "C"  },
  { email: "jaylen.t@ahs.student.edu",  first: "Jaylen",  last: "Thompson", dob: Date.new(2009, 1, 31), grade: "10", jersey: "3",  pos: "PG" },
  { email: "devon.m@ahs.student.edu",   first: "Devon",   last: "Mitchell", dob: Date.new(2009, 7, 22), grade: "10", jersey: "44", pos: "SF" },
  { email: "caleb.w@ahs.student.edu",   first: "Caleb",   last: "Washington", dob: Date.new(2009, 3, 8), grade: "10", jersey: "7",  pos: "SG" },
  { email: "ryan.p2@ahs.student.edu",   first: "Ryan",    last: "Patel",    dob: Date.new(2010, 9, 15), grade: "9",  jersey: "21", pos: "PF" },
  { email: "trevor.o@ahs.student.edu",  first: "Trevor",  last: "Osei",     dob: Date.new(2010, 5, 27), grade: "9",  jersey: "0",  pos: "C"  }
]

bball_player_users = bball_players.map do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: ahs_bball_season) do |sm|
    sm.role = :student; sm.grade = attrs[:grade]; sm.level = "varsity"
    sm.jersey_number = attrs[:jersey]; sm.position = attrs[:pos]; sm.is_captain = attrs[:captain] || false
  end
  u
end

# Basketball parents
bball_parent_1 = User.find_or_create_by!(email: "david.w@example.com") do |u|
  u.first_name = "David"; u.last_name = "Williams"; u.password = "password123"
end
bball_parent_2 = User.find_or_create_by!(email: "patricia.c@example.com") do |u|
  u.first_name = "Patricia"; u.last_name = "Carter"; u.password = "password123"
end

desmond_user = User.find_by!(email: "desmond.c@ahs.student.edu")
isaiah_user  = User.find_by!(email: "isaiah.w@ahs.student.edu")

SeasonMembership.find_or_create_by!(user: bball_parent_1, season: ahs_bball_season) { |sm| sm.role = :parent }
SeasonMembership.find_or_create_by!(user: bball_parent_2, season: ahs_bball_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: bball_parent_1, student: isaiah_user)
ParentStudentRelationship.find_or_create_by!(parent: bball_parent_2, student: desmond_user)

bball_general = Channel.find_or_create_by!(season: ahs_bball_season, name: "general") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :conversation; c.system_generated = true
end
bball_announcements = Channel.find_or_create_by!(season: ahs_bball_season, name: "announcements") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :broadcast; c.system_generated = true
end
bball_coaches = Channel.find_or_create_by!(season: ahs_bball_season, name: "coaches") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :coaches_only; c.system_generated = true
end

all_bball = [ ahs_basketball_coach, ahs_basketball_asst ] + bball_player_users + [ bball_parent_1, bball_parent_2 ]
all_bball.each { |u| ChannelMembership.find_or_create_by!(channel: bball_general, user: u) }
all_bball.each { |u| ChannelMembership.find_or_create_by!(channel: bball_announcements, user: u) }
[ ahs_basketball_coach, ahs_basketball_asst ].each { |u| ChannelMembership.find_or_create_by!(channel: bball_coaches, user: u) }

Message.find_or_create_by!(channel: bball_announcements, sender: ahs_basketball_coach,
  content: "Season is officially underway! First practice Dec 2, 6am in the main gym. No exceptions — be early.")
Message.find_or_create_by!(channel: bball_announcements, sender: ahs_basketball_coach,
  content: "Home opener vs Crest is Jan 15. Tip-off 7pm. Dress code for the bus — look sharp.")
Message.find_or_create_by!(channel: bball_general, sender: desmond_user,
  content: "Let's get it — this is our year. Who's been putting up shots this week?")
Message.find_or_create_by!(channel: bball_general, sender: isaiah_user,
  content: "Every day. Also been working on ball handling with Jay — he's looking good.")
Message.find_or_create_by!(channel: bball_general, sender: User.find_by!(email: "jaylen.t@ahs.student.edu"),
  content: "Appreciate that 💪 Coach, are we doing 3-man weave drills Tuesday?")
Message.find_or_create_by!(channel: bball_general, sender: ahs_basketball_coach,
  content: "Yes — and film review right after. Make sure you've all watched the Crest game tape I sent.")

bball_flagged = Message.find_or_create_by!(channel: bball_general, sender: isaiah_user,
  content: "Crest's point guard is straight trash, we're going to embarrass them on their own court 😂") do |m|
  m.flagged = true; m.moderation_score = 0.61
  m.flag_reason = "Derogatory language targeting an opponent player"
  m.flag_action = "held"
end

Message.find_or_create_by!(channel: bball_coaches, sender: ahs_basketball_coach,
  content: "Tyra — flagged one from Isaiah in general. Same pattern as last year. Let's check in with him before Thursday.")
Message.find_or_create_by!(channel: bball_coaches, sender: ahs_basketball_asst,
  content: "On it. He's been a little wound up. I'll pull him aside after Tuesday's practice.")

Activity.find_or_create_by!(subject_type: "Message", subject_id: bball_flagged.id) do |a|
  a.event_type  = :message_flagged; a.actor = isaiah_user
  a.season      = ahs_bball_season; a.school = ahs; a.occurred_at = 3.days.ago
  a.metadata    = { tier: "questionable", flag_action: "held", flag_reason: bball_flagged.flag_reason,
                    sport: ahs_boys_basketball.name, season: ahs_bball_season.name, channel: "general" }
end

ModerationNotification.find_or_create_by!(recipient: ahs_basketball_coach, message: bball_flagged,
  notification_type: :questionable_review, recipient_role: :head_coach)
ModerationNotification.find_or_create_by!(recipient: ahs_ad, message: bball_flagged,
  notification_type: :questionable_review, recipient_role: :athletic_director)

# ── AHS Track & Field — roster + channels ─────────────────────────────────────

tf_athletes = [
  { email: "zara.a@ahs.student.edu",   first: "Zara",   last: "Ahmed",     dob: Date.new(2007, 4, 20), grade: "12", pos: "800m",    captain: true },
  { email: "lucas.f@ahs.student.edu",  first: "Lucas",  last: "Fernandez", dob: Date.new(2008, 9,  3), grade: "11", pos: "100m/200m" },
  { email: "amara.o@ahs.student.edu",  first: "Amara",  last: "Okafor",    dob: Date.new(2008, 2, 28), grade: "11", pos: "Long Jump" },
  { email: "ben.k@ahs.student.edu",    first: "Ben",    last: "Kowalski",  dob: Date.new(2009, 6, 11), grade: "10", pos: "Shot Put" },
  { email: "fatima.h@ahs.student.edu", first: "Fatima", last: "Hassan",    dob: Date.new(2009, 11, 7), grade: "10", pos: "1500m"    },
  { email: "jake.m@ahs.student.edu",   first: "Jake",   last: "Miller",    dob: Date.new(2010, 1, 25), grade: "9",  pos: "110m Hurdles" }
]

tf_player_users = tf_athletes.map do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: ahs_tf_season) do |sm|
    sm.role = :student; sm.grade = attrs[:grade]; sm.level = "varsity"
    sm.position = attrs[:pos]; sm.is_captain = attrs[:captain] || false
  end
  u
end

tf_general = Channel.find_or_create_by!(season: ahs_tf_season, name: "general") do |c|
  c.created_by = ahs_tf_coach; c.channel_type = :conversation; c.system_generated = true
end
tf_announcements = Channel.find_or_create_by!(season: ahs_tf_season, name: "announcements") do |c|
  c.created_by = ahs_tf_coach; c.channel_type = :broadcast; c.system_generated = true
end

(tf_player_users + [ ahs_tf_coach, ahs_tf_asst ]).each do |u|
  ChannelMembership.find_or_create_by!(channel: tf_general, user: u)
  ChannelMembership.find_or_create_by!(channel: tf_announcements, user: u)
end

Message.find_or_create_by!(channel: tf_announcements, sender: ahs_tf_coach,
  content: "Track & Field 2025-26 is officially open. Season runs March 1 through June 1. Training plan posted in the school portal.")
Message.find_or_create_by!(channel: tf_general, sender: User.find_by!(email: "zara.a@ahs.student.edu"),
  content: "Excited for this season. Already hitting 2:18 in the 800 in training — want to get to 2:10 by Conference.")
Message.find_or_create_by!(channel: tf_general, sender: ahs_tf_coach,
  content: "That's a realistic goal, Zara. Let's map out your peaking schedule this week.")
Message.find_or_create_by!(channel: tf_general, sender: User.find_by!(email: "lucas.f@ahs.student.edu"),
  content: "Coach Santos — any chance we do some relay practice before the first invitational?")
Message.find_or_create_by!(channel: tf_general, sender: ahs_tf_coach,
  content: "Relay lineups go up Thursday. Come ready to race.")

CalendarEvent.find_or_create_by!(sport: ahs_tf, title: "Riverside Invitational", starts_at: Date.new(2026, 3, 28).to_time + 9.hours) do |e|
  e.created_by = ahs_tf_coach; e.event_type = :meet; e.home_away = :home; e.location = "AHS Track"
  e.ends_at = Date.new(2026, 3, 28).to_time + 15.hours; e.status = :scheduled
  e.notes = "8 schools competing. Field events start at 9am, running events 11am."
end
CalendarEvent.find_or_create_by!(sport: ahs_tf, title: "KingCo Championships", starts_at: Date.new(2026, 5, 16).to_time + 9.hours) do |e|
  e.created_by = ahs_tf_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "Eastside Athletics Complex"
  e.ends_at = Date.new(2026, 5, 16).to_time + 18.hours; e.status = :scheduled
end

# ── BHS Boys Swimming — enrich roster ─────────────────────────────────────────

bhs_boys_swim_athletes = [
  { email: "tyler.m@bhs.student.edu",  first: "Tyler",  last: "Morrison", dob: Date.new(2007, 5,  4), grade: "12", pos: "Freestyle",   level: "varsity" },
  { email: "kenji.n@bhs.student.edu",  first: "Kenji",  last: "Nakamura", dob: Date.new(2008, 10, 17), grade: "11", pos: "Butterfly",   level: "varsity" },
  { email: "cole.s@bhs.student.edu",   first: "Cole",   last: "Sanders",  dob: Date.new(2009, 3, 29), grade: "10", pos: "Backstroke",  level: "varsity" },
  { email: "finn.o@bhs.student.edu",   first: "Finn",   last: "O'Brien",  dob: Date.new(2009, 8,  1), grade: "10", pos: "Freestyle",   level: "jv"      }
]

# Enrich existing BHS boy swim members
sm = SeasonMembership.find_by!(user: bhs_swim_student_1, season: bhs_swim_season)
sm.update_columns(grade: "12", level: "varsity", position: "IM", is_captain: true)
sm = SeasonMembership.find_by!(user: bhs_swim_student_2, season: bhs_swim_season)
sm.update_columns(grade: "11", level: "varsity", position: "Breaststroke")

bhs_boys_swim_athletes.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: bhs_swim_season) do |sm2|
    sm2.role = :student; sm2.grade = attrs[:grade]; sm2.level = attrs[:level]; sm2.position = attrs[:pos]
  end
end

bhs_boys_swim_general = Channel.find_or_create_by!(season: bhs_swim_season, name: "general") do |c|
  c.created_by = bhs_swim_coach; c.channel_type = :conversation; c.system_generated = true
end
bhs_boys_swim_announcements = Channel.find_or_create_by!(season: bhs_swim_season, name: "announcements") do |c|
  c.created_by = bhs_swim_coach; c.channel_type = :broadcast; c.system_generated = true
end

bhs_boys_all = [ bhs_swim_coach, head_coach, bhs_swim_student_1, bhs_swim_student_2 ] +
               User.where(email: bhs_boys_swim_athletes.map { _1[:email] }).to_a
bhs_boys_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_general, user: u) }
bhs_boys_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_announcements, user: u) }

Message.find_or_create_by!(channel: bhs_boys_swim_announcements, sender: bhs_swim_coach,
  content: "BHS Boys Swimming 2025-26 is underway. First practice Monday at 6am in the main pool. No tardiness.")
Message.find_or_create_by!(channel: bhs_boys_swim_general, sender: bhs_swim_student_1,
  content: "Looking to repeat as KingCo champs this year. Let's lock in early.")
Message.find_or_create_by!(channel: bhs_boys_swim_general, sender: head_coach,
  content: "Big goals. Let's make sure the training backs it up — I'll be at practices Tuesdays and Thursdays.")

# ── BHS Girls Swimming — enrich roster ────────────────────────────────────────

bhs_girls_swim_athletes = [
  { email: "ava.t@bhs.student.edu",       first: "Ava",      last: "Thompson", dob: Date.new(2007, 6, 14), grade: "12", pos: "Freestyle",    captain: true },
  { email: "mia.r@bhs.student.edu",       first: "Mia",      last: "Rodriguez", dob: Date.new(2008, 2, 28), grade: "11", pos: "Butterfly"    },
  { email: "isabelle.w@bhs.student.edu",  first: "Isabelle", last: "Wong",     dob: Date.new(2009, 10,  3), grade: "10", pos: "Backstroke"   },
  { email: "grace.l@bhs.student.edu",     first: "Grace",    last: "Lee",      dob: Date.new(2008, 8, 19), grade: "11", pos: "Breaststroke"  }
]

bhs_girls_swim_athletes.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: bhs_girls_swim_season) do |sm2|
    sm2.role = :student; sm2.grade = attrs[:grade]; sm2.level = "varsity"
    sm2.position = attrs[:pos]; sm2.is_captain = attrs[:captain] || false
  end
end

bhs_girls_general = Channel.find_or_create_by!(season: bhs_girls_swim_season, name: "general") do |c|
  c.created_by = bhs_girls_swim_coach; c.channel_type = :conversation; c.system_generated = true
end
bhs_girls_announcements = Channel.find_or_create_by!(season: bhs_girls_swim_season, name: "announcements") do |c|
  c.created_by = bhs_girls_swim_coach; c.channel_type = :broadcast; c.system_generated = true
end

bhs_girls_all = [ bhs_girls_swim_coach ] + User.where(email: bhs_girls_swim_athletes.map { _1[:email] }).to_a
bhs_girls_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_girls_general, user: u) }
bhs_girls_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_girls_announcements, user: u) }

Message.find_or_create_by!(channel: bhs_girls_announcements, sender: bhs_girls_swim_coach,
  content: "Welcome to Girls Swimming BHS 2025-26! Season starts Dec 1. Weekly practice schedule posted on the athletics board.")
Message.find_or_create_by!(channel: bhs_girls_general, sender: User.find_by!(email: "ava.t@bhs.student.edu"),
  content: "Can't believe it's my last season. Let's make it count, everyone 🏊‍♀️")
Message.find_or_create_by!(channel: bhs_girls_general, sender: bhs_girls_swim_coach,
  content: "Ava sets the standard. Learn from her leadership, freshmen.")

# ── CHS Girls Swimming — roster + channels ────────────────────────────────────

chs_girls_swim_athletes = [
  { email: "olivia.f@chs.student.edu",   first: "Olivia",   last: "Foster",  dob: Date.new(2007, 7, 30), grade: "12", pos: "Freestyle",   captain: true },
  { email: "samantha.c@chs.student.edu", first: "Samantha", last: "Cruz",    dob: Date.new(2008, 3, 12), grade: "11", pos: "Backstroke"   },
  { email: "erin.w@chs.student.edu",     first: "Erin",     last: "Walsh",   dob: Date.new(2009, 9, 22), grade: "10", pos: "Breaststroke"  },
  { email: "katie.k@chs.student.edu",    first: "Katie",    last: "Kim",     dob: Date.new(2010, 5,  6), grade: "9",  pos: "Butterfly"    }
]

chs_girls_swim_athletes.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: chs_swim_season) do |sm2|
    sm2.role = :student; sm2.grade = attrs[:grade]; sm2.level = "varsity"
    sm2.position = attrs[:pos]; sm2.is_captain = attrs[:captain] || false
  end
end

chs_general = Channel.find_or_create_by!(season: chs_swim_season, name: "general") do |c|
  c.created_by = chs_swim_coach; c.channel_type = :conversation; c.system_generated = true
end
chs_announcements = Channel.find_or_create_by!(season: chs_swim_season, name: "announcements") do |c|
  c.created_by = chs_swim_coach; c.channel_type = :broadcast; c.system_generated = true
end

chs_all = [ chs_swim_coach ] + User.where(email: chs_girls_swim_athletes.map { _1[:email] }).to_a
chs_all.each { |u| ChannelMembership.find_or_create_by!(channel: chs_general, user: u) }
chs_all.each { |u| ChannelMembership.find_or_create_by!(channel: chs_announcements, user: u) }

Message.find_or_create_by!(channel: chs_announcements, sender: chs_swim_coach,
  content: "Eagles Swim is back! Season opens Dec 1. Conditioning starts this week — pool time 6–7:30am.")
Message.find_or_create_by!(channel: chs_general, sender: User.find_by!(email: "olivia.f@chs.student.edu"),
  content: "Let's shock everyone at the KingCo meet this year. Eagles don't get enough credit.")
Message.find_or_create_by!(channel: chs_general, sender: chs_swim_coach,
  content: "Prove it in the water, Olivia. That's all I'll say 😤")

# ── BHS Boys Basketball — roster ──────────────────────────────────────────────

bhs_bball_players = [
  { email: "andre.w@bhs.student.edu",  first: "Andre",   last: "Williams", dob: Date.new(2007, 11, 4), grade: "12", jersey: "1",  pos: "PG", captain: true },
  { email: "carlos.m@bhs.student.edu", first: "Carlos",  last: "Mendez",   dob: Date.new(2008, 4, 18), grade: "11", jersey: "30", pos: "PF" },
  { email: "malik.g@bhs.student.edu",  first: "Malik",   last: "Green",    dob: Date.new(2008, 9,  7), grade: "11", jersey: "24", pos: "SF" },
  { email: "jarvis.c@bhs.student.edu", first: "Jarvis",  last: "Clark",    dob: Date.new(2009, 2, 15), grade: "10", jersey: "8",  pos: "SG" },
  { email: "darius.k@bhs.student.edu", first: "Darius",  last: "King",     dob: Date.new(2009, 7, 30), grade: "10", jersey: "11", pos: "C"  }
]

bhs_bball_players.each do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: bhs_bball_season) do |sm2|
    sm2.role = :student; sm2.grade = attrs[:grade]; sm2.level = "varsity"
    sm2.jersey_number = attrs[:jersey]; sm2.position = attrs[:pos]; sm2.is_captain = attrs[:captain] || false
  end
end

bhs_bball_general = Channel.find_or_create_by!(season: bhs_bball_season, name: "general") do |c|
  c.created_by = bhs_basketball_coach; c.channel_type = :conversation; c.system_generated = true
end
bhs_bball_announcements = Channel.find_or_create_by!(season: bhs_bball_season, name: "announcements") do |c|
  c.created_by = bhs_basketball_coach; c.channel_type = :broadcast; c.system_generated = true
end

bhs_bball_all = [ bhs_basketball_coach ] + User.where(email: bhs_bball_players.map { _1[:email] }).to_a
bhs_bball_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_bball_general, user: u) }
bhs_bball_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_bball_announcements, user: u) }

Message.find_or_create_by!(channel: bhs_bball_announcements, sender: bhs_basketball_coach,
  content: "Knights Basketball 2025-26 is underway. Practice is 6am Monday, Wednesday, Friday. Be there.")
Message.find_or_create_by!(channel: bhs_bball_general, sender: User.find_by!(email: "andre.w@bhs.student.edu"),
  content: "Knights run this district. Prove everyone wrong this season 💪")

# BHS cross-school incident — gives district admin something to see from a second school
bhs_bball_severe = Message.find_or_create_by!(channel: bhs_bball_general,
  sender: User.find_by!(email: "carlos.m@bhs.student.edu"),
  content: "If Alfred wins this year it's because the refs are rigged for them. I'm going to make sure everyone knows.") do |m|
  m.flagged = true; m.moderation_score = 0.84
  m.flag_reason = "Accusation of officiating bias; potential to incite conflict between school communities"
  m.flag_action = "blocked"
end

Activity.find_or_create_by!(subject_type: "Message", subject_id: bhs_bball_severe.id) do |a|
  a.event_type  = :message_flagged; a.actor = User.find_by!(email: "carlos.m@bhs.student.edu")
  a.season      = bhs_bball_season; a.school = bhs; a.occurred_at = 12.hours.ago
  a.metadata    = { tier: "severe", flag_action: "blocked", flag_reason: bhs_bball_severe.flag_reason,
                    sport: bhs_boys_basketball.name, season: bhs_bball_season.name, channel: "general" }
end

ModerationNotification.find_or_create_by!(recipient: bhs_basketball_coach, message: bhs_bball_severe,
  notification_type: :severe_alert, recipient_role: :head_coach)
ModerationNotification.find_or_create_by!(recipient: bhs_ad, message: bhs_bball_severe,
  notification_type: :severe_alert, recipient_role: :athletic_director)
Notification.find_or_create_by!(recipient: district_admin, notification_type: "moderation_alert",
  body: "Severe content flagged in #{bhs_boys_basketball.name} at #{bhs.name} — general channel") do |n|
  n.title    = "Severe content flagged"
  n.metadata = { sport: bhs_boys_basketball.name, school: bhs.name, flag_action: "blocked" }.to_json
  n.created_at = 12.hours.ago; n.updated_at = 12.hours.ago
end

# ── Additional DMs for head coach (Chris Nguyen) ──────────────────────────────

dm_coach_emma = DmConversation.between(head_coach, User.find_by!(email: "emma.j@ahs.student.edu"), swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_emma, sender: head_coach,
  content: "Emma — your backstroke start has improved a lot. Want to talk about peaking strategy for KingCo?")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_emma, sender: User.find_by!(email: "emma.j@ahs.student.edu"),
  content: "Yes please! I'm targeting a 1:02 in the 100 back. Is that realistic?")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_emma, sender: head_coach,
  content: "With your current trajectory, absolutely. Let's map it out Thursday.")

dm_coach_bhs_parent = DmConversation.between(head_coach, bhs_swim_student_1, bhs_swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_bhs_parent, sender: bhs_swim_coach,
  content: "Marcus — Coach Nguyen will be running Tuesday's practice. Treat him like you treat me.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_bhs_parent, sender: bhs_swim_student_1,
  content: "Understood Coach Kim. We'll bring the intensity.")

# ── Additional basketball calendar events ─────────────────────────────────────

CalendarEvent.find_or_create_by!(sport: ahs_boys_basketball, title: "vs Crest High School (Away)", starts_at: Date.new(2026, 2, 3).to_time + 19.hours) do |e|
  e.created_by = ahs_basketball_coach; e.event_type = :game; e.home_away = :away; e.location = "CHS Gymnasium"
  e.opponent = "Crest High School"; e.ends_at = Date.new(2026, 2, 3).to_time + 21.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: ahs_boys_basketball, title: "KingCo Tournament — Quarterfinals", starts_at: Date.new(2026, 2, 25).to_time + 18.hours) do |e|
  e.created_by = ahs_basketball_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "KingCo Arena"
  e.ends_at = Date.new(2026, 2, 25).to_time + 20.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: bhs_boys_basketball, title: "vs Alfred High School (Home)", starts_at: Date.new(2026, 1, 29).to_time + 19.hours) do |e|
  e.created_by = bhs_basketball_coach; e.event_type = :game; e.home_away = :home; e.location = "BHS Gymnasium"
  e.opponent = "Alfred High School"; e.ends_at = Date.new(2026, 1, 29).to_time + 21.hours; e.status = :scheduled
end
CalendarEvent.find_or_create_by!(sport: bhs_boys_basketball, title: "KingCo Tournament — Quarterfinals", starts_at: Date.new(2026, 2, 25).to_time + 20.hours) do |e|
  e.created_by = bhs_basketball_coach; e.event_type = :tournament; e.home_away = :neutral; e.location = "KingCo Arena"
  e.ends_at = Date.new(2026, 2, 25).to_time + 22.hours; e.status = :scheduled
end

# ── Safety access notifications ───────────────────────────────────────────────
# Simulate coaches having accessed safety chats — district admin sees these.
[
  { accessor: head_coach,           role: "Head Coach", school: ahs.name, names: "Jordan Lee",    ago: 2.days,   keyword: nil },
  { accessor: head_coach,           role: "Head Coach", school: ahs.name, names: "Jordan Lee",    ago: 5.days,  keyword: "practice" },
  { accessor: bhs_swim_coach,       role: "Head Coach",        school: bhs.name, names: "Marcus Tran",   ago: 8.days,  keyword: nil },
  { accessor: bhs_ad,               role: "Athletic Director", school: bhs.name, names: "Taylor Brooks", ago: 12.days, keyword: nil },
  { accessor: ahs_basketball_coach, role: "Head Coach",        school: ahs.name, names: "Carlos Mendez", ago: 15.days, keyword: "tournament" }
].each do |row|
  Notification.find_or_create_by!(
    recipient:         district_admin,
    notification_type: "safety_chat_access",
    body:              "#{row[:accessor].full_name} (#{row[:role]} · #{row[:school]}) accessed student chats — searched: #{row[:names]}#{row[:keyword] ? " | keyword: \"#{row[:keyword]}\"" : ''}",
  ) do |n|
    n.title    = "Safety: Chat Viewer Access"
    n.metadata = { accessor_name: row[:accessor].full_name, accessor_role: row[:role], accessor_schools: [ row[:school] ], searched_names: row[:names] }.to_json
    n.created_at = row[:ago].ago
    n.updated_at = row[:ago].ago
  end
end

# ── Coach start dates ────────────────────────────────────────────────────────
# Assign realistic random past start dates to all coach institution roles.
# Anchored to Aug 1 or Jan 1 (typical season starts), spread over the last 4 years.
COACH_START_ANCHORS = [
  Date.new(2021, 8, 1), Date.new(2022, 1, 1), Date.new(2022, 8, 1),
  Date.new(2023, 1, 1), Date.new(2023, 8, 1), Date.new(2024, 1, 1),
  Date.new(2024, 8, 1), Date.new(2025, 1, 1)
].freeze

InstitutionRole.where(role: %i[head_coach assistant_coach]).find_each do |r|
  r.update_columns(start_date: COACH_START_ANCHORS.sample)
end

# ── Eastlake High School ──────────────────────────────────────────────────────

ehs = School.find_or_create_by!(name: "Eastlake High School", district: hsd) do |s|
  s.city   = "Riverside"
  s.state  = "WA"
  s.active = true
end

ehs_ad = User.find_or_create_by!(email: "ad@ehs.edu") do |u|
  u.first_name = "Sandra"
  u.last_name  = "Reyes"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: ehs_ad, role: :athletic_director, school: ehs) { |r| r.start_date = Date.current }

ehs_swim_coach = User.find_or_create_by!(email: "coach.swim@ehs.edu") do |u|
  u.first_name = "Kevin"
  u.last_name  = "Walsh"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: ehs_swim_coach, role: :head_coach, school: ehs) { |r| r.start_date = Date.current }

ehs_swim_asst = User.find_or_create_by!(email: "asst.swim@ehs.edu") do |u|
  u.first_name = "Amy"
  u.last_name  = "Torres"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: ehs_swim_asst, role: :assistant_coach, school: ehs) { |r| r.start_date = Date.current }

ehs_girls_swimming = Sport.find_or_create_by!(sport_template: swim_template, school: ehs, gender: :girls) do |s|
  s.status = :active
end

ehs_swim_season = Season.find_or_create_by!(sport: ehs_girls_swimming, school_year: "2025-26") do |s|
  s.name      = "Girls Swimming EHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 2, 28)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: ehs_swim_coach, season: ehs_swim_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ehs_swim_asst,  season: ehs_swim_season) { |sm| sm.role = :assistant_coach }

# ── Venues ────────────────────────────────────────────────────────────────────

Venue.create!(name: "AHS Aquatic Center", school: ahs, facility_type: "pool",
  address: "1234 Alfred Blvd, Riverside, WA 98001",
  availability: [
    { "id" => "v1-a1", "days" => [ 1, 3, 5 ], "start_time" => "15:00", "end_time" => "19:00" },
    { "id" => "v1-a2", "days" => [ 6 ],        "start_time" => "09:00", "end_time" => "16:00" },
  ])

Venue.create!(name: "BHS Natatorium", school: bhs, facility_type: "pool",
  address: "5678 Baldwin Way, Riverside, WA 98004",
  availability: [
    { "id" => "v2-a1", "days" => [ 2, 4 ], "start_time" => "15:30", "end_time" => "19:00" },
    { "id" => "v2-a2", "days" => [ 6 ],    "start_time" => "10:00", "end_time" => "17:00" },
  ])

Venue.create!(name: "Crest Natatorium", school: chs, facility_type: "pool",
  address: "9012 Crest Dr, Riverside, WA 98007",
  availability: [
    { "id" => "v3-a1", "days" => [ 1, 3 ], "start_time" => "15:00", "end_time" => "18:30" },
    { "id" => "v3-a2", "days" => [ 6 ],    "start_time" => "09:00", "end_time" => "14:00" },
  ])

Venue.create!(name: "EHS Aquatic Center", school: ehs, facility_type: "pool",
  address: "3456 Eastlake Ave, Riverside, WA 98008",
  availability: [
    { "id" => "v4-a1", "days" => [ 2, 4 ], "start_time" => "14:30", "end_time" => "18:00" },
  ])

# ── Commissioner Events ───────────────────────────────────────────────────────

ahs_t = { "sport_id" => swimming.id,           "school_id" => ahs.id, "school_name" => ahs.name, "team_name" => "AHS Girls Swim"   }
bhs_t = { "sport_id" => bhs_girls_swimming.id,  "school_id" => bhs.id, "school_name" => bhs.name, "team_name" => "BHS Girls Swim"   }
chs_t = { "sport_id" => chs_girls_swimming.id,  "school_id" => chs.id, "school_name" => chs.name, "team_name" => "Crest Girls Swim" }
ehs_t = { "sport_id" => ehs_girls_swimming.id,  "school_id" => ehs.id, "school_name" => ehs.name, "team_name" => "EHS Girls Swim"   }

[
  { title: "#{ahs.name} vs #{bhs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-01-15T15:00:00", ends_at: "2026-01-15T18:00:00", venue: "AHS Aquatic Center",
    teams: [ ahs_t, bhs_t ], matchup_pairs: [ { "home_school_id" => ahs.id, "away_school_id" => bhs.id } ],
    status: "completed", has_results: true, result_summary: "AHS 134 – BHS 112" },

  { title: "#{bhs.name} vs #{chs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-01-22T15:00:00", ends_at: "2026-01-22T18:00:00", venue: "BHS Natatorium",
    teams: [ bhs_t, chs_t ], matchup_pairs: [ { "home_school_id" => bhs.id, "away_school_id" => chs.id } ],
    status: "completed", has_results: true, result_summary: "BHS 128 – Crest 89" },

  { title: "#{ahs.name} vs #{chs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-02-05T15:00:00", ends_at: "2026-02-05T18:00:00", venue: "AHS Aquatic Center",
    teams: [ ahs_t, chs_t ], matchup_pairs: [ { "home_school_id" => ahs.id, "away_school_id" => chs.id } ],
    status: "completed", has_results: true, result_summary: "AHS 142 – Crest 98" },

  { title: "#{bhs.name} vs #{ahs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-02-12T15:00:00", ends_at: "2026-02-12T18:00:00", venue: "BHS Natatorium",
    teams: [ bhs_t, ahs_t ], matchup_pairs: [ { "home_school_id" => bhs.id, "away_school_id" => ahs.id } ],
    status: "completed", has_results: false,
    notes: "Results uploaded by BHS — pending AHS confirmation." },

  { title: "Girls Swimming — Double Dual", event_type: "meet",
    starts_at: "2026-02-19T15:00:00", ends_at: "2026-02-19T18:00:00", venue: "AHS Aquatic Center",
    teams: [ ahs_t, bhs_t, chs_t, ehs_t ],
    matchup_pairs: [
      { "home_school_id" => ahs.id, "away_school_id" => ehs.id },
      { "home_school_id" => chs.id, "away_school_id" => bhs.id },
    ],
    status: "completed", has_results: true,
    result_summary: "AHS 128 – EHS 108 · Crest 91 – BHS 115" },

  { title: "#{chs.name} vs #{bhs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-03-04T15:00:00", ends_at: "2026-03-04T18:00:00", venue: "Crest Natatorium",
    teams: [ chs_t, bhs_t ], matchup_pairs: [ { "home_school_id" => chs.id, "away_school_id" => bhs.id } ],
    status: "completed", has_results: true, result_summary: "Crest 97 – BHS 119" },

  { title: "Girls Swimming — Double Dual", event_type: "meet",
    starts_at: "2026-03-18T15:00:00", ends_at: "2026-03-18T18:00:00", venue: "EHS Aquatic Center",
    teams: [ ehs_t, ahs_t, bhs_t, chs_t ],
    matchup_pairs: [
      { "home_school_id" => ehs.id, "away_school_id" => bhs.id },
      { "home_school_id" => ahs.id, "away_school_id" => chs.id },
    ],
    status: "completed", has_results: true,
    result_summary: "EHS 122 – BHS 114 · AHS 136 – Crest 89" },

  { title: "#{ahs.name} vs #{bhs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-04-09T15:00:00", ends_at: "2026-04-09T18:00:00", venue: "AHS Aquatic Center",
    teams: [ ahs_t, bhs_t ], matchup_pairs: [ { "home_school_id" => ahs.id, "away_school_id" => bhs.id } ],
    status: "postponed", has_results: false,
    notes: "Postponed due to pool maintenance at AHS." },

  { title: "#{ahs.name} vs #{bhs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-05-14T14:00:00", ends_at: "2026-05-14T17:00:00", venue: "AHS Aquatic Center",
    teams: [ ahs_t, bhs_t ], matchup_pairs: [ { "home_school_id" => ahs.id, "away_school_id" => bhs.id } ],
    status: "scheduled", has_results: false },

  { title: "Girls Swimming — Double Dual", event_type: "meet",
    starts_at: "2026-05-16T14:00:00", ends_at: "2026-05-16T17:00:00", venue: "BHS Natatorium",
    teams: [ bhs_t, ahs_t, ehs_t, chs_t ],
    matchup_pairs: [
      { "home_school_id" => bhs.id, "away_school_id" => ahs.id },
      { "home_school_id" => ehs.id, "away_school_id" => chs.id },
    ],
    status: "scheduled", has_results: false,
    notes: "BHS hosting. Pool split: lanes 1-4 BHS vs AHS, lanes 5-8 EHS vs Crest." },

  { title: "KingCo Championships — Prelims", event_type: "tournament",
    starts_at: "2026-05-20T08:00:00", ends_at: "2026-05-20T18:00:00", venue: "King County Aquatic Center",
    teams: [ ahs_t, bhs_t, chs_t, ehs_t ], matchup_pairs: [],
    status: "scheduled", has_results: false,
    notes: "All KingCo schools competing. Check in no later than 7:30 AM." },

  { title: "#{ahs.name} vs #{ehs.name} — Girls Swimming", event_type: "meet",
    starts_at: "2026-05-27T15:00:00", ends_at: "2026-05-27T18:00:00", venue: "EHS Aquatic Center",
    teams: [ ahs_t, ehs_t ], matchup_pairs: [ { "home_school_id" => ehs.id, "away_school_id" => ahs.id } ],
    status: "scheduled", has_results: false, notes: "Away meet at Eastlake." },

  { title: "KingCo Championships — Finals", event_type: "tournament",
    starts_at: "2026-06-03T09:00:00", ends_at: "2026-06-03T20:00:00", venue: "King County Aquatic Center",
    teams: [ ahs_t, bhs_t, chs_t, ehs_t ], matchup_pairs: [],
    status: "scheduled", has_results: false },
].each do |attrs|
  CommissionerEvent.create!(
    sport_template:  swim_template,
    district:        hsd,
    title:           attrs[:title],
    event_type:      attrs[:event_type],
    starts_at:       attrs[:starts_at],
    ends_at:         attrs[:ends_at],
    venue:           attrs[:venue],
    teams:           attrs[:teams],
    matchup_pairs:   attrs[:matchup_pairs] || [],
    status:          attrs[:status],
    has_results:     attrs.fetch(:has_results, false),
    result_summary:  attrs[:result_summary],
    notes:           attrs[:notes] || ""
  )
end

# ── Accessibility Defaults ────────────────────────────────────────────────────
# Runs last so it catches every user created anywhere in this file.
# Safe to re-run: merges defaults under existing prefs, never overwrites them.

ACCESSIBILITY_DEFAULTS = { "font_size" => "default" }.freeze

User.find_each do |u|
  merged = ACCESSIBILITY_DEFAULTS.merge(u.accessibility)
  u.update_columns(accessibility: merged) if merged != u.accessibility
end

# ── Time Standards (Girls Swimming) ──────────────────────────────────────────

[
  { event: "200 Medley Relay",      kingco: "1:55.00", districts_wildcard: "1:53.50", districts: "1:52.00", state: "1:49.00" },
  { event: "200 Freestyle",         kingco: "2:08.00", districts_wildcard: "2:05.00", districts: "2:03.00", state: "1:59.00" },
  { event: "200 Individual Medley", kingco: "2:22.00", districts_wildcard: "2:18.00", districts: "2:17.00", state: "2:13.00" },
  { event: "50 Freestyle",          kingco: "26.50",   districts_wildcard: "26.00",   districts: "25.80",   state: "25.20"   },
  { event: "100 Butterfly",         kingco: "1:03.50", districts_wildcard: "1:02.00", districts: "1:01.50", state: "1:00.50" },
  { event: "100 Freestyle",         kingco: "57.00",   districts_wildcard: "56.50",   districts: "55.50",   state: "54.50"   },
  { event: "500 Freestyle",         kingco: "5:35.00", districts_wildcard: "5:28.00", districts: "5:22.00", state: "5:12.00" },
  { event: "200 Free Relay",        kingco: "1:45.50", districts_wildcard: "1:44.00", districts: "1:43.50", state: "1:41.00" },
  { event: "100 Backstroke",        kingco: "1:04.50", districts_wildcard: "1:04.00", districts: "1:03.50", state: "1:02.00" },
  { event: "100 Breaststroke",      kingco: "1:16.00", districts_wildcard: "1:14.50", districts: "1:13.00", state: "1:11.50" },
  { event: "400 Free Relay",        kingco: "3:55.00", districts_wildcard: "3:52.50", districts: "3:51.00", state: "3:47.00" },
].each do |row|
  TimeStandard.create!(sport_template: swim_template, gender: "girls",
    event_name: row[:event], kingco: row[:kingco],
    districts_wildcard: row[:districts_wildcard], districts: row[:districts], state: row[:state])
end

# ── Meet Results ──────────────────────────────────────────────────────────────

r1 = MeetResult.create!(
  sport: swimming, home_school: ahs, away_school: bhs,
  date: "2026-01-15", venue: "AHS Aquatic Center",
  home_score: 134, away_score: 112,
  status: "published",
  uploaded_by: head_coach,
  ai_summary: "Alfred High Girls Swimming won a strong home dual meet 134–112 over Baldwin. Taylor Brooks posted a meet-best 1:01.4 in the 100 Butterfly — a 2.8% improvement and her fastest split of the season, now ranking her 5th in the district. The 200 Medley Relay opened at 1:51.9, four seconds ahead of last season's team average. AHS swept all freestyle events and led breaststroke. Baldwin showed individual strength in backstroke, with Grace Okafor winning that event at 1:03.2.",
  ai_focus: "500 Freestyle margin was narrower than projected. Recommend adding distance sets in the next two training weeks ahead of the KingCo qualifier.",
  events: [
    { "event" => "100 Butterfly",  "results" => [
      { "place" => 1, "athlete" => "Taylor Brooks", "school" => "AHS", "time" => "1:01.4", "personal_best" => true },
      { "place" => 2, "athlete" => "Alex Turner",   "school" => "BHS", "time" => "1:04.2" } ] },
    { "event" => "50 Freestyle",   "results" => [
      { "place" => 1, "athlete" => "Alex Rivera",  "school" => "AHS", "time" => "25.2" },
      { "place" => 2, "athlete" => "Sofia Reyes",  "school" => "BHS", "time" => "26.1" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Grace Okafor", "school" => "BHS", "time" => "1:03.2" },
      { "place" => 2, "athlete" => "Jordan Lee",   "school" => "AHS", "time" => "1:03.5" } ] },
    { "event" => "200 Free Relay", "results" => [
      { "place" => 1, "athlete" => "AHS Relay", "school" => "AHS", "time" => "1:43.1", "personal_best" => true },
      { "place" => 2, "athlete" => "BHS Relay", "school" => "BHS", "time" => "1:45.8" } ] },
  ]
)
r1.ai_standouts = [
  "Taylor Brooks (AHS) — 100 Fly: 1:01.4 · Season PR · District rank #5",
  "200 Medley Relay (AHS) — 1:51.9 · Team season best",
]
r1.save!

r2 = MeetResult.create!(
  sport: bhs_girls_swimming, home_school: bhs, away_school: chs,
  date: "2026-01-22", venue: "BHS Natatorium",
  home_score: 128, away_score: 89,
  cross_division: true,
  status: "published",
  uploaded_by: bhs_girls_swim_coach,
  ai_summary: "Baldwin Girls Swimming claimed a decisive 128–89 win over 3A Crest in this cross-division meet. While the divisional gap favored BHS, the meet generated quality racing — Crest's Maya Chen posted the sharpest 200 IM split of the meet at 2:14.8, pushing Baldwin swimmers to season-best efforts in that event. Sofia Reyes (BHS) went 28.1 in the 50 Free, her fastest of the season. Cross-division results do not count toward KingCo standings but individual times are eligible for district qualifying consideration.",
  ai_focus: "Commissioner note: cross-division results are non-scoring for KingCo standings but individual times count toward qualifying consideration.",
  events: [
    { "event" => "200 Individual Medley", "results" => [
      { "place" => 1, "athlete" => "Maya Chen",   "school" => "Crest", "time" => "2:14.8", "personal_best" => true },
      { "place" => 2, "athlete" => "Alex Turner", "school" => "BHS",   "time" => "2:17.3" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Sofia Reyes", "school" => "BHS",   "time" => "28.1", "personal_best" => true },
      { "place" => 2, "athlete" => "Lily Torres", "school" => "Crest", "time" => "29.8" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Grace Okafor", "school" => "BHS",   "time" => "1:02.8" },
      { "place" => 2, "athlete" => "Priya Patel",  "school" => "Crest", "time" => "1:06.4" } ] },
    { "event" => "400 Free Relay", "results" => [
      { "place" => 1, "athlete" => "BHS Relay",   "school" => "BHS",   "time" => "3:52.4" },
      { "place" => 2, "athlete" => "Crest Relay", "school" => "Crest", "time" => "4:01.1" } ] },
  ]
)
r2.ai_standouts = [
  "Maya Chen (Crest) — 200 IM: 2:14.8 · Season PR",
  "Sofia Reyes (BHS) — 50 Free: 28.1 · Season PR",
]
r2.save!

r3 = MeetResult.create!(
  sport: swimming, home_school: ahs, away_school: chs,
  date: "2026-02-05", venue: "AHS Aquatic Center",
  home_score: 142, away_score: 98,
  cross_division: true,
  status: "pending_commissioner",
  uploaded_by: head_coach,
  ai_summary: "AHS continued its strong season with a 142–98 home win over 3A Crest. The divisional gap was expected, but individual matchups produced quality mid-season racing. Jordan Lee (AHS) dropped 1.4 seconds in the 100 Backstroke, finishing at 1:02.1 — now ranked 4th in the district this season. Priya Patel (Crest) competed well across multiple events, posting a 2:08.3 in the 200 Free that supports her individual qualifying effort. AHS relay teams averaged 3.1% faster than their January splits.",
  ai_focus: "JV roster depth needs more competitive experience before the district qualifier. Recommend adding a JV exhibition at the next home meet.",
  events: [
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Jordan Lee",  "school" => "AHS",   "time" => "1:02.1", "personal_best" => true },
      { "place" => 2, "athlete" => "Priya Patel", "school" => "Crest", "time" => "1:05.7" } ] },
    { "event" => "200 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Mia Santos",  "school" => "AHS",   "time" => "2:06.4" },
      { "place" => 2, "athlete" => "Priya Patel", "school" => "Crest", "time" => "2:08.3" } ] },
    { "event" => "100 Breaststroke", "results" => [
      { "place" => 1, "athlete" => "Zoe Kim",   "school" => "AHS",   "time" => "1:11.8" },
      { "place" => 2, "athlete" => "Maya Chen", "school" => "Crest", "time" => "1:13.2" } ] },
    { "event" => "200 Free Relay", "results" => [
      { "place" => 1, "athlete" => "AHS Relay",   "school" => "AHS",   "time" => "1:42.8", "personal_best" => true },
      { "place" => 2, "athlete" => "Crest Relay", "school" => "Crest", "time" => "1:49.3" } ] },
  ]
)
r3.ai_standouts = [
  "Jordan Lee (AHS) — 100 Back: 1:02.1 · Season PR · District rank #4",
  "200 Free Relay (AHS) — 1:42.8 · Season PR",
]
r3.save!

r4 = MeetResult.create!(
  sport: swimming, home_school: bhs, away_school: ahs,
  date: "2026-02-12", venue: "BHS Natatorium",
  home_score: 118, away_score: 125,
  status: "pending_opponent",
  uploaded_by: bhs_girls_swim_coach,
  ai_summary: "Tight road win for AHS Girls Swimming, 125–118 at Baldwin — the closest margin of the season and the most competitive dual meet to date. Alex Rivera (AHS) delivered a clutch 100 Freestyle at 55.3, edging Baldwin's Grace Okafor (55.9) by 0.6 seconds. The 400 Free Relay proved decisive: AHS closed in 3:48.2 to Baldwin's 3:52.1. Both teams traded leads through the middle of the meet. This result moves AHS to 3–0 heading into KingCo.",
  ai_focus: "Monitor butterfly rotation depth — Taylor Brooks rested in the final event. Relay flexibility in that stroke will matter at KingCo.",
  events: [
    { "event" => "100 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Alex Rivera",  "school" => "AHS", "time" => "55.3", "personal_best" => true },
      { "place" => 2, "athlete" => "Grace Okafor", "school" => "BHS", "time" => "55.9" } ] },
    { "event" => "100 Butterfly", "results" => [
      { "place" => 1, "athlete" => "Taylor Brooks", "school" => "AHS", "time" => "1:00.8", "personal_best" => true },
      { "place" => 2, "athlete" => "Alex Turner",   "school" => "BHS", "time" => "1:03.7" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Sofia Reyes", "school" => "BHS", "time" => "27.9", "personal_best" => true },
      { "place" => 2, "athlete" => "Alex Rivera", "school" => "AHS", "time" => "28.2" } ] },
    { "event" => "400 Free Relay", "results" => [
      { "place" => 1, "athlete" => "AHS Relay", "school" => "AHS", "time" => "3:48.2", "personal_best" => true },
      { "place" => 2, "athlete" => "BHS Relay", "school" => "BHS", "time" => "3:52.1" } ] },
  ]
)
r4.ai_standouts = [
  "Alex Rivera (AHS) — 100 Free: 55.3 · Season PR",
  "Taylor Brooks (AHS) — 100 Fly: 1:00.8 · Season PR",
  "400 Free Relay (AHS) — 3:48.2 · Season PR",
]
r4.save!

water_polo_sport = water_polo
r5 = MeetResult.create!(
  sport: water_polo_sport, home_school: ahs, away_school: bhs,
  date: "2025-10-03", venue: "AHS Aquatic Center",
  home_score: 11, away_score: 8,
  status: "published",
  uploaded_by: head_coach,
  ai_summary: "AHS Boys Water Polo opened league play with a convincing 11–8 home win over Baldwin. Casey Lee led with 4 goals and 2 assists. AHS outscored Baldwin 6–2 in the second half after trailing 4–5 at halftime — a strong comeback showing depth in the second unit.",
  events: []
)
r5.ai_standouts = [
  "Casey Lee (AHS) — 4 goals, 2 assists",
  "Marcus Hill (AHS) — 3 goals, shutout quarter in goal",
]
r5.save!

r6 = MeetResult.create!(
  sport: water_polo_sport, home_school: chs, away_school: ahs,
  date: "2025-10-17", venue: "Crest Aquatic Park",
  home_score: 13, away_score: 8,
  status: "published",
  uploaded_by: head_coach,
  ai_summary: "A tough road loss for AHS — Crest's press defense held AHS to just 3 goals in the first three quarters. Casey Lee and Dion Carter combined for 6 of AHS's 8 goals. Crest's center forward was dominant in the second quarter, scoring 5 unanswered. AHS finished the season 8–3.",
  ai_focus: "Press defense coverage was the key weakness — worth addressing before playoffs.",
  events: []
)
r6.ai_standouts = [
  "Casey Lee (AHS) — 4 goals",
  "Dion Carter (AHS) — 2 goals",
]
r6.save!

# ── Qualification Flags (auto-derived from published results) ─────────────────

[
  { result: r1, athlete: "Taylor Brooks",     school: "AHS",   event: "100 Butterfly",       time: "1:01.4", level: "kingco",            standard: "1:03.50", status: "accepted" },
  { result: r1, athlete: "Taylor Brooks",     school: "AHS",   event: "100 Butterfly",       time: "1:01.4", level: "districts_wildcard", standard: "1:02.00", status: "pending"  },
  { result: r1, athlete: "Taylor Brooks",     school: "AHS",   event: "100 Butterfly",       time: "1:01.4", level: "districts",          standard: "1:01.50", status: "pending"  },
  { result: r1, athlete: "Alex Rivera",       school: "AHS",   event: "50 Freestyle",        time: "25.2",   level: "state",              standard: "25.20",   status: "pending"  },
  { result: r1, athlete: "Alex Rivera",       school: "AHS",   event: "50 Freestyle",        time: "25.2",   level: "districts",          standard: "25.80",   status: "pending"  },
  { result: r1, athlete: "Jordan Lee",        school: "AHS",   event: "100 Backstroke",      time: "1:03.5", level: "kingco",             standard: "1:04.50", status: "pending"  },
  { result: r1, athlete: "Grace Okafor",      school: "BHS",   event: "100 Backstroke",      time: "1:03.2", level: "districts",          standard: "1:03.50", status: "pending"  },
  { result: r1, athlete: "AHS 200 Free Relay", school: "AHS",  event: "200 Free Relay",      time: "1:43.1", level: "kingco",             standard: "1:45.50", status: "pending"  },
  { result: r1, athlete: "AHS 200 Free Relay", school: "AHS",  event: "200 Free Relay",      time: "1:43.1", level: "districts",          standard: "1:43.50", status: "pending"  },
  { result: r2, athlete: "Maya Chen",         school: "Crest", event: "200 Individual Medley", time: "2:14.8", level: "kingco",           standard: "2:22.00", status: "pending"  },
  { result: r2, athlete: "Maya Chen",         school: "Crest", event: "200 Individual Medley", time: "2:14.8", level: "districts_wildcard", standard: "2:18.00", status: "pending" },
  { result: r2, athlete: "BHS 400 Free Relay", school: "BHS",  event: "400 Free Relay",      time: "3:52.4", level: "kingco",              standard: "3:55.00", status: "pending"  },
  { result: r2, athlete: "BHS 400 Free Relay", school: "BHS",  event: "400 Free Relay",      time: "3:52.4", level: "districts_wildcard",  standard: "3:52.50", status: "pending"  },
].each do |f|
  QualificationFlag.create!(
    meet_result:   f[:result],
    athlete_name:  f[:athlete],
    school_abbr:   f[:school],
    event_name:    f[:event],
    time_str:      f[:time],
    level:         f[:level],
    standard_time: f[:standard],
    status:        f[:status]
  )
end

# ── Spread message timestamps ─────────────────────────────────────────────────
# Distribute messages across the past ~4 weeks so date-range filtering is
# meaningful in the demo. Run on every seed so re-seeds stay consistent.
msgs = Message.order(:id).to_a
msgs.each_with_index do |m, i|
  days_ago   = ((msgs.count - i).to_f / msgs.count * 28).ceil
  hour       = 8 + (i * 2) % 10   # 8..17 — always valid
  min_offset = (i * 7) % 60
  new_time   = days_ago.days.ago.change(hour: hour, min: min_offset, sec: 0)
  m.update_columns(created_at: new_time, updated_at: new_time)
end

puts "Done! Seeded HSD scenario:"
puts "  District:  #{District.count}"
puts "  Schools:   #{School.count}"
puts "  Users:     #{User.count}"
puts "  Sports:    #{Sport.count}"
puts "  Seasons:   #{Season.count}"
puts "  Channels:  #{Channel.count}"
puts "  Messages:  #{Message.count}"
puts "  Themes:    #{Theme.count} (#{Theme.system.count} system, #{Theme.school.count} school)"
