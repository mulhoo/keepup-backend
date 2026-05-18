# Seed data for local development — HSD (Hajos School District) demo scenario.
# Run with: bin/rails db:seed
# Safe to re-run: structural records use find_or_create_by!; mutable demo state
# is explicitly reset so every demo run (including "End Demo") starts clean.

if $stdin.tty?
  print "This will reset demo state and re-seed the database. Continue? [y/N] "
  exit unless $stdin.gets.chomp.downcase == 'y'
end

puts "Seeding KeepUp development data..."

# Mutable demo state — wiped on every seed run so every demo starts clean.
ParentViewRequest.destroy_all
SafetyReviewSignal.destroy_all
QualificationFlag.delete_all
MeetResult.delete_all
TimeStandard.delete_all
Notification.update_all(read_at: nil)

# Clear all channel messages and related records so every seed run starts fresh.
ModerationNotification.where.not(message_id: nil).delete_all
MessageChallenge.delete_all
Reaction.where.not(message_id: nil).delete_all
MessageTranslation.delete_all
Message.update_all(message_thread_id: nil)   # break circular FK before deleting threads
MessageThread.delete_all
Message.delete_all

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

baseball_template = SportTemplate.find_or_initialize_by(district: hsd, name: "Baseball")
baseball_template.assign_attributes(athletic_season: :spring, gender_config: :separate, active: true)
baseball_template.save!

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

ahs_baseball_coach = User.find_or_create_by!(email: "coach.baseball@ahs.edu") do |u|
  u.first_name = "Ray"
  u.last_name  = "Cortez"
  u.password   = "password123"
end

ahs_baseball_asst = User.find_or_create_by!(email: "asst.baseball@ahs.edu") do |u|
  u.first_name = "Tom"
  u.last_name  = "Briggs"
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
InstitutionRole.find_or_create_by!(user: ahs_tf_coach,       role: :head_coach,       school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_baseball_coach, role: :head_coach,       school: ahs)
InstitutionRole.find_or_create_by!(user: ahs_baseball_asst,  role: :assistant_coach,  school: ahs)
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

ahs_boys_baseball = Sport.find_or_create_by!(sport_template: baseball_template, school: ahs, gender: :boys) do |s|
  s.status = :active
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
  ChannelMembership.find_or_create_by!(channel: ch, user: ahs_ad)
end

polo_parent_coaches = Channel.find_or_create_by!(season: polo_season, name: "parent-coaches") do |c|
  c.created_by = head_coach; c.channel_type = :family_group; c.system_generated = true
end
[ head_coach, ahs_ad ].each { |u| ChannelMembership.find_or_create_by!(channel: polo_parent_coaches, user: u) }
SeasonMembership.where(season: polo_season, role: :parent).includes(:user).each do |sm|
  ChannelMembership.find_or_create_by!(channel: polo_parent_coaches, user: sm.user)
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

ahs_soccer_student = User.find_or_create_by!(email: "sofia.n@ahs.student.edu") do |u|
  u.first_name = "Sofia"; u.last_name = "Navarro"; u.password = "password123"; u.dob = Date.new(2008, 3, 14)
end
SeasonMembership.find_or_create_by!(user: ahs_soccer_student, season: ahs_soccer_season) do |sm|
  sm.role = :student; sm.grade = "11"; sm.level = "varsity"; sm.position = "Midfielder"
end

ahs_tf_season = Season.find_or_create_by!(sport: ahs_tf, school_year: "2025-26") do |s|
  s.sport     = ahs_tf
  s.name      = "Track & Field AHS 2025-26"
  s.starts_at = Date.new(2026, 3, 1)
  s.ends_at   = Date.new(2026, 6, 1)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: ahs_tf_coach, season: ahs_tf_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ahs_tf_asst,  season: ahs_tf_season) { |sm| sm.role = :assistant_coach }

ahs_baseball_season = Season.find_or_create_by!(sport: ahs_boys_baseball, school_year: "2025-26") do |s|
  s.sport     = ahs_boys_baseball
  s.name      = "Baseball AHS 2025-26"
  s.starts_at = Date.new(2026, 3, 1)
  s.ends_at   = Date.new(2026, 6, 7)
  s.status    = :active
end
SeasonMembership.find_or_create_by!(user: ahs_baseball_coach, season: ahs_baseball_season) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ahs_baseball_asst,  season: ahs_baseball_season) { |sm| sm.role = :assistant_coach }

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

# ── Past Seasons (2024-25, archived) ─────────────────────────────────────────
# These demonstrate the active vs. completed season split in the UI.

# AHS Girls Swimming 2024-25 ──────────────────────────────────────────────────
swim_season_prev = Season.find_or_create_by!(sport: swimming, school_year: "2024-25") do |s|
  s.name      = "Girls Swimming AHS 2024-25"
  s.starts_at = Date.new(2024, 12, 2)
  s.ends_at   = Date.new(2025, 2, 22)
  s.status    = :archived
end

SeasonMembership.find_or_create_by!(user: head_coach,      season: swim_season_prev) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: asst_coach,      season: swim_season_prev) { |sm| sm.role = :assistant_coach }
SeasonMembership.find_or_create_by!(user: student_captain, season: swim_season_prev) { |sm| sm.role = :student; sm.is_captain = true }
SeasonMembership.find_or_create_by!(user: student_1,       season: swim_season_prev) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: student_2,       season: swim_season_prev) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: parent_1,        season: swim_season_prev) { |sm| sm.role = :parent }
SeasonMembership.find_or_create_by!(user: captain_parent,  season: swim_season_prev) { |sm| sm.role = :parent }

swim_prev_general = Channel.find_or_create_by!(season: swim_season_prev, name: "general") do |c|
  c.created_by = head_coach; c.channel_type = :conversation; c.system_generated = true
end
swim_prev_announcements = Channel.find_or_create_by!(season: swim_season_prev, name: "announcements") do |c|
  c.created_by = head_coach; c.channel_type = :broadcast; c.system_generated = true
end
swim_prev_athletes = Channel.find_or_create_by!(season: swim_season_prev, name: "athletes") do |c|
  c.created_by = head_coach; c.channel_type = :athletes_only; c.system_generated = true
end

[swim_prev_general, swim_prev_announcements].each do |ch|
  [head_coach, asst_coach, student_captain, student_1, student_2, parent_1, captain_parent].each do |u|
    ChannelMembership.find_or_create_by!(channel: ch, user: u)
  end
end
[student_captain, student_1, student_2].each do |u|
  ChannelMembership.find_or_create_by!(channel: swim_prev_athletes, user: u)
end

Message.find_or_create_by!(channel: swim_prev_announcements, sender: head_coach,
  content: "Season wrap-up: congratulations on a fantastic 2024-25 campaign. Finals results posted to the school athletics page. Proud of every one of you.")
Message.find_or_create_by!(channel: swim_prev_announcements, sender: head_coach,
  content: "League championship meet is Saturday at 9am — arrive by 8am for warmup. Travel permission slips due Friday.")
Message.find_or_create_by!(channel: swim_prev_general, sender: student_captain,
  content: "Anyone else's 200 free dropping? Coach Chris has us on a new sprint set and I'm already feeling it in a good way")
Message.find_or_create_by!(channel: swim_prev_general, sender: student_1,
  content: "That set was brutal lol. See you all Saturday — let's bring home the banner 🏊")
Message.find_or_create_by!(channel: swim_prev_general, sender: asst_coach,
  content: "Great energy at practice today. Travel roster confirmed and posted. Check in with me if you have questions.")
Message.find_or_create_by!(channel: swim_prev_athletes, sender: student_captain,
  content: "Captains meeting recap: we're doing a team dinner Thursday before the championship. DM me if you need a ride.")

# AHS Boys Water Polo 2024-25 ─────────────────────────────────────────────────
polo_season_prev = Season.find_or_create_by!(sport: water_polo, school_year: "2024-25") do |s|
  s.name      = "Boys Water Polo AHS 2024-25"
  s.starts_at = Date.new(2024, 9, 3)
  s.ends_at   = Date.new(2024, 11, 9)
  s.status    = :archived
end

SeasonMembership.find_or_create_by!(user: head_coach,    season: polo_season_prev) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: polo_coach,    season: polo_season_prev) { |sm| sm.role = :assistant_coach }
SeasonMembership.find_or_create_by!(user: student_3,     season: polo_season_prev) { |sm| sm.role = :student; sm.is_captain = true }
SeasonMembership.find_or_create_by!(user: polo_student_1, season: polo_season_prev) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: polo_student_2, season: polo_season_prev) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: polo_student_3, season: polo_season_prev) { |sm| sm.role = :student }

polo_prev_general = Channel.find_or_create_by!(season: polo_season_prev, name: "general") do |c|
  c.created_by = head_coach; c.channel_type = :conversation; c.system_generated = true
end
polo_prev_announcements = Channel.find_or_create_by!(season: polo_season_prev, name: "announcements") do |c|
  c.created_by = head_coach; c.channel_type = :broadcast; c.system_generated = true
end

[polo_prev_general, polo_prev_announcements].each do |ch|
  [head_coach, polo_coach, student_3, polo_student_1, polo_student_2, polo_student_3].each do |u|
    ChannelMembership.find_or_create_by!(channel: ch, user: u)
  end
end

Message.find_or_create_by!(channel: polo_prev_announcements, sender: head_coach,
  content: "Water polo 2024-25 is officially wrapped — 11-3 record, KingCo semifinalists. Incredible season. Banquet details coming next week.")
Message.find_or_create_by!(channel: polo_prev_announcements, sender: head_coach,
  content: "Quarterfinal tomorrow vs. Eastside Prep, 6pm at the AHS pool. This is it — bring the energy we've been building all season.")
Message.find_or_create_by!(channel: polo_prev_general, sender: student_3,
  content: "That win against Riverside Central was ELECTRIC. 7-6 in OT — Mateo's final goal was insane")
Message.find_or_create_by!(channel: polo_prev_general, sender: polo_student_1,
  content: "Best season I've had. Same team next year?")
Message.find_or_create_by!(channel: polo_prev_general, sender: polo_coach,
  content: "Proud of the whole squad. See you all at the banquet — details from Coach Chris soon.")

# AHS Boys Basketball 2024-25 ─────────────────────────────────────────────────
bball_season_prev = Season.find_or_create_by!(sport: ahs_boys_basketball, school_year: "2024-25") do |s|
  s.name      = "Boys Basketball AHS 2024-25"
  s.starts_at = Date.new(2024, 12, 2)
  s.ends_at   = Date.new(2025, 3, 8)
  s.status    = :archived
end

SeasonMembership.find_or_create_by!(user: ahs_basketball_coach, season: bball_season_prev) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: ahs_basketball_asst,  season: bball_season_prev) { |sm| sm.role = :assistant_coach }

bball_prev_general = Channel.find_or_create_by!(season: bball_season_prev, name: "general") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :conversation; c.system_generated = true
end
bball_prev_announcements = Channel.find_or_create_by!(season: bball_season_prev, name: "announcements") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :broadcast; c.system_generated = true
end

[bball_prev_general, bball_prev_announcements].each do |ch|
  [ahs_basketball_coach, ahs_basketball_asst].each do |u|
    ChannelMembership.find_or_create_by!(channel: ch, user: u)
  end
end

Message.find_or_create_by!(channel: bball_prev_announcements, sender: ahs_basketball_coach,
  content: "2024-25 season complete — 14-8, district tournament appearance. Film review Tuesday at 4pm before we break for spring.")
Message.find_or_create_by!(channel: bball_prev_announcements, sender: ahs_basketball_coach,
  content: "Practice moved to the auxiliary gym tomorrow — main gym is reserved for SATs. Same time, 3:30pm.")
Message.find_or_create_by!(channel: bball_prev_general, sender: ahs_basketball_asst,
  content: "Shootaround times for Saturday posted on the whiteboard. Be there 45 min before tip-off.")

# BHS Boys Swimming 2024-25 ───────────────────────────────────────────────────
bhs_swim_season_prev = Season.find_or_create_by!(sport: bhs_boys_swimming, school_year: "2024-25") do |s|
  s.name      = "Boys Swimming BHS 2024-25"
  s.starts_at = Date.new(2024, 12, 2)
  s.ends_at   = Date.new(2025, 2, 22)
  s.status    = :archived
end

SeasonMembership.find_or_create_by!(user: bhs_swim_coach,     season: bhs_swim_season_prev) { |sm| sm.role = :head_coach }
SeasonMembership.find_or_create_by!(user: bhs_swim_student_1, season: bhs_swim_season_prev) { |sm| sm.role = :student }
SeasonMembership.find_or_create_by!(user: bhs_swim_student_2, season: bhs_swim_season_prev) { |sm| sm.role = :student }

bhs_swim_prev_general = Channel.find_or_create_by!(season: bhs_swim_season_prev, name: "general") do |c|
  c.created_by = bhs_swim_coach; c.channel_type = :conversation; c.system_generated = true
end
bhs_swim_prev_announcements = Channel.find_or_create_by!(season: bhs_swim_season_prev, name: "announcements") do |c|
  c.created_by = bhs_swim_coach; c.channel_type = :broadcast; c.system_generated = true
end

[bhs_swim_prev_general, bhs_swim_prev_announcements].each do |ch|
  [bhs_swim_coach, bhs_swim_student_1, bhs_swim_student_2].each do |u|
    ChannelMembership.find_or_create_by!(channel: ch, user: u)
  end
end

Message.find_or_create_by!(channel: bhs_swim_prev_announcements, sender: bhs_swim_coach,
  content: "Season's done — 8-4 on the year. Huge thanks to Marcus and Leo for leading this group. Hotel check-out for state travel is 6am Sunday.")
Message.find_or_create_by!(channel: bhs_swim_prev_general, sender: bhs_swim_student_1,
  content: "Coach Tony — any chance we can get the training plan for the off-season?")
Message.find_or_create_by!(channel: bhs_swim_prev_general, sender: bhs_swim_coach,
  content: "Sending it out by end of week. Keep the yardage up through spring break, Marcus.")

# ── Parent-Student Relationship ───────────────────────────────────────────────

ParentStudentRelationship.find_or_create_by!(parent: parent_1,       student: student_1)
ParentStudentRelationship.find_or_create_by!(parent: parent_1,       student: student_3)
ParentStudentRelationship.find_or_create_by!(parent: captain_parent, student: student_captain)

# ── Additional Parent-Student Relationships ───────────────────────────────────

# Ryan Lee — Jordan's sibling, also in swim_season.
# Morgan Lee (parent_1) now has two kids in the same season — exercises the
# "two kids in one season" path in the family groups flow.
ryan_lee = User.find_or_create_by!(email: "ryan.lee@ahs.student.edu") do |u|
  u.first_name = "Ryan"; u.last_name = "Lee"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: ryan_lee, season: swim_season) { |sm| sm.role = :student }
ParentStudentRelationship.find_or_create_by!(parent: parent_1, student: ryan_lee)

# Fix: Diane Rivera (polo_parent_2) was seeded without a child link
ParentStudentRelationship.find_or_create_by!(parent: polo_parent_2, student: polo_student_1)

# Dana Brooks — parent of Taylor Brooks (student_2) in swim_season
dana_brooks = User.find_or_create_by!(email: "dana.brooks@example.com") do |u|
  u.first_name = "Dana"; u.last_name = "Brooks"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: dana_brooks, season: swim_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: dana_brooks, student: student_2)

# Kenji Nakamura — parent of Eli Nakamura (polo_student_3)
kenji_nakamura = User.find_or_create_by!(email: "kenji.nakamura@example.com") do |u|
  u.first_name = "Kenji"; u.last_name = "Nakamura"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: kenji_nakamura, season: polo_season) { |sm| sm.role = :parent }
ChannelMembership.find_or_create_by!(channel: polo_general,        user: kenji_nakamura)
ChannelMembership.find_or_create_by!(channel: polo_announcements,  user: kenji_nakamura)
ParentStudentRelationship.find_or_create_by!(parent: kenji_nakamura, student: polo_student_3)

# Grace Okonkwo — parent of Sam Okonkwo (polo_student_4)
grace_okonkwo = User.find_or_create_by!(email: "grace.okonkwo@example.com") do |u|
  u.first_name = "Grace"; u.last_name = "Okonkwo"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: grace_okonkwo, season: polo_season) { |sm| sm.role = :parent }
ChannelMembership.find_or_create_by!(channel: polo_general,        user: grace_okonkwo)
ChannelMembership.find_or_create_by!(channel: polo_announcements,  user: grace_okonkwo)
ParentStudentRelationship.find_or_create_by!(parent: grace_okonkwo, student: polo_student_4)

# James Tran — parent of Marcus Tran (bhs_swim_student_1)
james_tran = User.find_or_create_by!(email: "james.tran@example.com") do |u|
  u.first_name = "James"; u.last_name = "Tran"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: james_tran, season: bhs_swim_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: james_tran, student: bhs_swim_student_1)

# Erik Svensson — parent of Leo Svensson (bhs_swim_student_2)
erik_svensson = User.find_or_create_by!(email: "erik.svensson@example.com") do |u|
  u.first_name = "Erik"; u.last_name = "Svensson"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: erik_svensson, season: bhs_swim_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: erik_svensson, student: bhs_swim_student_2)

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
  [ head_coach, asst_coach, student_captain, student_1, student_2, parent_1, captain_parent, dana_brooks ].each do |user|
    ChannelMembership.find_or_create_by!(channel: channel, user: user)
  end
end

[ athletes_only ].each do |channel|
  [ student_captain, student_1, student_2, ryan_lee ].each do |user|
    ChannelMembership.find_or_create_by!(channel: channel, user: user)
  end
end

# Ryan Lee (student) joins general + announcements; dana_brooks (parent) already added above
ChannelMembership.find_or_create_by!(channel: general,       user: ryan_lee)
ChannelMembership.find_or_create_by!(channel: announcements, user: ryan_lee)
ChannelMembership.find_or_create_by!(channel: general,       user: ahs_ad)
ChannelMembership.find_or_create_by!(channel: announcements, user: ahs_ad)

swim_parent_coaches = Channel.find_or_create_by!(season: swim_season, name: "parent-coaches") do |c|
  c.created_by = head_coach; c.channel_type = :family_group; c.system_generated = true
end
[ head_coach, asst_coach, ahs_ad ].each { |u| ChannelMembership.find_or_create_by!(channel: swim_parent_coaches, user: u) }
SeasonMembership.where(season: swim_season, role: :parent).includes(:user).each do |sm|
  ChannelMembership.find_or_create_by!(channel: swim_parent_coaches, user: sm.user)
end

# ── Announcements channel ─────────────────────────────────────────────────────

msg_welcome = Message.create!(channel: announcements, sender: head_coach,
  content: "Welcome to the 2025-26 swim season! First practice is Monday at 6am — bring your own cap and goggles. Can't wait to get back in the water with you all. 🏊",
  pinned_at: 2.weeks.ago, pinned_by: head_coach)

Message.create!(channel: announcements, sender: head_coach,
  content: "Important: all athletes must submit updated physical forms to the front office by Friday. No physical on file = no practice. DM me if you need the form.")

Message.create!(channel: announcements, sender: asst_coach,
  content: "November meet schedule is live on the athletics page. First away meet is Nov 14 @ Baldwin — bus departs at 3:30pm sharp. Parent volunteers needed for carpool coordination — reach out to me or Coach Nguyen.")

Message.create!(channel: announcements, sender: head_coach,
  content: "Time trials are this Thursday. Get solid sleep Tuesday and Wednesday — we want clean data on where everyone is starting the season.")

# ── General channel ───────────────────────────────────────────────────────────

msg_general_1 = Message.create!(channel: general, sender: student_captain,
  content: "First week back 🙌 Who's been training over the summer? Let's hear it!")

thread_general_1 = MessageThread.create!(channel: general, parent_message: msg_general_1)
thread_general_1.messages.create!(channel: general, sender: student_1,
  content: "Open water swims at Riverside Lake all August. Feeling actually ready 🌊")
thread_general_1.messages.create!(channel: general, sender: student_2,
  content: "Same! Hit the gym too. Ready to get back in the pool.")
thread_general_1.messages.create!(channel: general, sender: ryan_lee,
  content: "Honestly no lol but I'm ready to suffer through week one 😅")
thread_general_1.messages.create!(channel: general, sender: student_captain,
  content: "That's the spirit Ryan 😂 See you all Monday!")
thread_general_1.update!(reply_count: thread_general_1.messages.count, last_reply_at: Time.current)

msg_general_2 = Message.create!(channel: general, sender: asst_coach,
  content: "Love the energy in here. Dry-land starts immediately at 6am Monday — don't be late, we're not waiting.")

msg_general_3 = Message.create!(channel: general, sender: student_2,
  content: "Anyone need a ride Monday? I have room for 2 from the BHS side 🚗")

thread_general_3 = MessageThread.create!(channel: general, parent_message: msg_general_3)
thread_general_3.messages.create!(channel: general, sender: ryan_lee,
  content: "Yes! I'm at BHS. What time are you leaving?")
thread_general_3.messages.create!(channel: general, sender: student_2,
  content: "Leaving at 5:30 — you're like 5 min away. I'll text you.")
thread_general_3.messages.create!(channel: general, sender: ryan_lee,
  content: "Perfect, thank you!")
thread_general_3.update!(reply_count: thread_general_3.messages.count, last_reply_at: Time.current)

msg_general_4 = Message.create!(channel: general, sender: student_1,
  content: "Coach Nguyen, quick question — are time trials still Thursday or did that change?")

thread_general_4 = MessageThread.create!(channel: general, parent_message: msg_general_4)
thread_general_4.messages.create!(channel: general, sender: head_coach,
  content: "Still Thursday, no changes. Rest up Wednesday.")
thread_general_4.messages.create!(channel: general, sender: student_1,
  content: "Got it! Is the A relay lineup posted yet?")
thread_general_4.messages.create!(channel: general, sender: head_coach,
  content: "Posting Friday after I see everyone's trial results. Focus on swimming well Thursday.")
thread_general_4.update!(reply_count: thread_general_4.messages.count, last_reply_at: Time.current)

# ── Questionable message — held, ⚠️ visible to Jordan (student_1) ─────────────
# Gemma scored this 0.52 — borderline trash talk before a meet.
# Delivers to everyone; coach sees a review notification (Gemma training only).

msg_questionable = Message.create!(channel: general, sender: student_1,
  content: "Baldwin better watch out, I'm going to absolutely destroy their relays 😤",
  flagged: true, moderation_score: 0.52,
  flag_reason: "Potentially aggressive language targeting another school's athletes",
  flag_action: "held")

msg_general_5 = Message.create!(channel: general, sender: head_coach,
  content: "Great first practice everyone. Energy was exactly what I was hoping for — let's keep it up tomorrow. 💪")

# ── Severe message — blocked, 🚫 visible only to Jordan ──────────────────────
# Gemma scored this 0.92. Blocked entirely. Coach + AD notified.

msg_severe = Message.create!(channel: general, sender: student_1,
  content: "I'm going to kill Coach if he benches me one more time",
  flagged: true, moderation_score: 0.92,
  flag_reason: "Direct threat toward a named person",
  flag_action: "blocked")

MessageChallenge.create!(
  message:    msg_severe,
  challenger: student_1,
  reason:     "I was just frustrated and venting — I would never actually hurt anyone. Please don't block me.",
)

# ── Athletes-only channel ─────────────────────────────────────────────────────

msg_athletes_1 = Message.create!(channel: athletes_only, sender: student_captain,
  content: "Team meeting Wednesday after practice — athletes only 🔒 Captains have an agenda.")

thread_athletes_1 = MessageThread.create!(channel: athletes_only, parent_message: msg_athletes_1)
thread_athletes_1.messages.create!(channel: athletes_only, sender: student_1,
  content: "What's on the agenda?")
thread_athletes_1.messages.create!(channel: athletes_only, sender: student_2,
  content: "Same question lol")
thread_athletes_1.messages.create!(channel: athletes_only, sender: student_captain,
  content: "Banquet planning and a fundraiser idea. Keep it in this channel for now.")
thread_athletes_1.messages.create!(channel: athletes_only, sender: ryan_lee,
  content: "Got it 👍")
thread_athletes_1.update!(reply_count: thread_athletes_1.messages.count, last_reply_at: Time.current)

msg_athletes_2 = Message.create!(channel: athletes_only, sender: student_2,
  content: "Fundraiser idea: bake sale one weekend, car wash the next. Both easy, both money 💰")

thread_athletes_2 = MessageThread.create!(channel: athletes_only, parent_message: msg_athletes_2)
thread_athletes_2.messages.create!(channel: athletes_only, sender: ryan_lee,
  content: "Car wash is more fun but bake sale makes more money per person")
thread_athletes_2.messages.create!(channel: athletes_only, sender: student_captain,
  content: "What if we did both? One before Baldwin, one before districts?")
thread_athletes_2.messages.create!(channel: athletes_only, sender: student_1,
  content: "I'm in for both")
thread_athletes_2.messages.create!(channel: athletes_only, sender: student_2,
  content: "Perfect. Bringing it to the meeting Wednesday 🙌")
thread_athletes_2.update!(reply_count: thread_athletes_2.messages.count, last_reply_at: Time.current)

# ── Coaches-only channel ──────────────────────────────────────────────────────

coaches_only = Channel.find_or_create_by!(season: swim_season, name: "coaches") do |c|
  c.created_by       = head_coach
  c.channel_type     = :coaches_only
  c.system_generated = true
end

ChannelMembership.find_or_create_by!(channel: coaches_only, user: head_coach)
ChannelMembership.find_or_create_by!(channel: coaches_only, user: asst_coach)

msg_coaches_1 = Message.create!(channel: coaches_only, sender: head_coach,
  content: "Dana — thinking about moving Jordan to the B relay this week. Times aren't where they need to be and I don't want to set them up to fail at Baldwin.")

thread_coaches_1 = MessageThread.create!(channel: coaches_only, parent_message: msg_coaches_1)
thread_coaches_1.messages.create!(channel: coaches_only, sender: asst_coach,
  content: "Agreed. Should we tell them before or after Wednesday's practice?")
thread_coaches_1.messages.create!(channel: coaches_only, sender: head_coach,
  content: "Before. Better they hear it from me directly than find out at the meet.")
thread_coaches_1.messages.create!(channel: coaches_only, sender: asst_coach,
  content: "I'll make sure I'm there when you tell them in case they need to talk through it.")
thread_coaches_1.update!(reply_count: thread_coaches_1.messages.count, last_reply_at: Time.current)

Message.create!(channel: coaches_only, sender: head_coach,
  content: "Also flagged Jordan's message in general for review. Coach Patel and I are keeping a close eye on the situation this week.")

# ── Reactions ─────────────────────────────────────────────────────────────────

Reaction.create!(message: msg_welcome,   user: student_captain, emoji: "🔥")
Reaction.create!(message: msg_welcome,   user: student_1,       emoji: "🔥")
Reaction.create!(message: msg_welcome,   user: student_2,       emoji: "👍")
Reaction.create!(message: msg_welcome,   user: ryan_lee,        emoji: "❤️")
Reaction.create!(message: msg_general_1, user: student_1,       emoji: "👍")
Reaction.create!(message: msg_general_1, user: student_2,       emoji: "❤️")
Reaction.create!(message: msg_general_2, user: student_1,       emoji: "😂")
Reaction.create!(message: msg_general_2, user: student_captain, emoji: "👍")
Reaction.create!(message: msg_general_3, user: ryan_lee,        emoji: "👍")
Reaction.create!(message: msg_general_4, user: student_captain, emoji: "👍")
Reaction.create!(message: msg_general_5, user: student_captain, emoji: "🔥")
Reaction.create!(message: msg_general_5, user: student_1,       emoji: "🔥")
Reaction.create!(message: msg_general_5, user: student_2,       emoji: "❤️")
Reaction.create!(message: msg_athletes_1, user: student_1,      emoji: "👍")
Reaction.create!(message: msg_athletes_1, user: student_2,      emoji: "👍")
Reaction.create!(message: msg_athletes_1, user: ryan_lee,       emoji: "👍")
Reaction.create!(message: msg_athletes_2, user: student_captain, emoji: "👍")
Reaction.create!(message: msg_athletes_2, user: ryan_lee,        emoji: "👍")
Reaction.create!(message: msg_coaches_1, user: asst_coach,      emoji: "👍")

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

# Jordan ↔ Alex Rivera (captain) — peer DM, no pending access request (shows "Request access")
dm_jordan_captain = DmConversation.between(student_1, student_captain, swim_season)
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_captain, sender: student_captain,
  content: "Hey Jordan — you killing it at practice lately. What's your 200 free time right now?")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_captain, sender: student_1,
  content: "1:58 last week. Trying to get under 1:55 before districts")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_captain, sender: student_captain,
  content: "That's solid. I'll pace you Thursday if you want")
DirectMessage.find_or_create_by!(dm_conversation: dm_jordan_captain, sender: student_1,
  content: "Yeah that'd actually help a lot, thanks")

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
# Using captain_parent (Lisa Rivera) here so that Morgan Lee's Jordan conversations
# default to "Request access" in the parent messages view — demonstrating both states.
ParentViewRequest.create!(
  parent: captain_parent,
  child:  student_captain,
  reason: "Alex has been quieter than usual lately and I noticed some tension after last week's practice. Just want to make sure everything is okay.",
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

marcus_j_user = User.find_by!(email: "marcus.j@ahs.student.edu")
kevin_johnson = User.find_or_create_by!(email: "kevin.johnson@example.com") do |u|
  u.first_name = "Kevin"; u.last_name = "Johnson"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: kevin_johnson, season: ahs_bball_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: kevin_johnson, student: marcus_j_user)

noah_g_user = User.find_by!(email: "noah.g@ahs.student.edu")
rachel_garcia = User.find_or_create_by!(email: "rachel.garcia@example.com") do |u|
  u.first_name = "Rachel"; u.last_name = "Garcia"; u.password = "password123"
end
SeasonMembership.find_or_create_by!(user: rachel_garcia, season: ahs_bball_season) { |sm| sm.role = :parent }
ParentStudentRelationship.find_or_create_by!(parent: rachel_garcia, student: noah_g_user)

bball_general = Channel.find_or_create_by!(season: ahs_bball_season, name: "general") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :conversation; c.system_generated = true
end
bball_announcements = Channel.find_or_create_by!(season: ahs_bball_season, name: "announcements") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :broadcast; c.system_generated = true
end
bball_coaches = Channel.find_or_create_by!(season: ahs_bball_season, name: "coaches") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :coaches_only; c.system_generated = true
end

all_bball = [ ahs_basketball_coach, ahs_basketball_asst ] + bball_player_users +
            [ bball_parent_1, bball_parent_2, kevin_johnson, rachel_garcia ]
all_bball.each { |u| ChannelMembership.find_or_create_by!(channel: bball_general, user: u) }
all_bball.each { |u| ChannelMembership.find_or_create_by!(channel: bball_announcements, user: u) }
[ ahs_basketball_coach, ahs_basketball_asst ].each { |u| ChannelMembership.find_or_create_by!(channel: bball_coaches, user: u) }
ChannelMembership.find_or_create_by!(channel: bball_general,       user: ahs_ad)
ChannelMembership.find_or_create_by!(channel: bball_announcements, user: ahs_ad)

bball_parent_coaches = Channel.find_or_create_by!(season: ahs_bball_season, name: "parent-coaches") do |c|
  c.created_by = ahs_basketball_coach; c.channel_type = :family_group; c.system_generated = true
end
[ ahs_basketball_coach, ahs_basketball_asst, ahs_ad ].each { |u| ChannelMembership.find_or_create_by!(channel: bball_parent_coaches, user: u) }
SeasonMembership.where(season: ahs_bball_season, role: :parent).includes(:user).each do |sm|
  ChannelMembership.find_or_create_by!(channel: bball_parent_coaches, user: sm.user)
end

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
ChannelMembership.find_or_create_by!(channel: tf_general,       user: ahs_ad)
ChannelMembership.find_or_create_by!(channel: tf_announcements, user: ahs_ad)

tf_parent_coaches = Channel.find_or_create_by!(season: ahs_tf_season, name: "parent-coaches") do |c|
  c.created_by = ahs_tf_coach; c.channel_type = :family_group; c.system_generated = true
end
[ ahs_tf_coach, ahs_tf_asst, ahs_ad ].each { |u| ChannelMembership.find_or_create_by!(channel: tf_parent_coaches, user: u) }
SeasonMembership.where(season: ahs_tf_season, role: :parent).includes(:user).each do |sm|
  ChannelMembership.find_or_create_by!(channel: tf_parent_coaches, user: sm.user)
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

# ── AHS Boys Baseball — roster + channels ─────────────────────────────────────

baseball_athletes = [
  { email: "marco.v@ahs.student.edu",  first: "Marco",  last: "Vasquez",   dob: Date.new(2007, 3, 12), grade: "12", pos: "Pitcher"     },
  { email: "derek.o@ahs.student.edu",  first: "Derek",  last: "Owens",     dob: Date.new(2007, 8, 29), grade: "12", pos: "Catcher"     },
  { email: "will.c@ahs.student.edu",   first: "Will",   last: "Callahan",  dob: Date.new(2008, 5,  4), grade: "11", pos: "Shortstop"   },
  { email: "jose.r@ahs.student.edu",   first: "Jose",   last: "Reyes",     dob: Date.new(2008, 11, 19), grade: "11", pos: "Center Field" },
  { email: "nate.h@ahs.student.edu",   first: "Nate",   last: "Hughes",    dob: Date.new(2009, 2, 22), grade: "10", pos: "First Base"  },
  { email: "elijah.b@ahs.student.edu", first: "Elijah", last: "Brooks",    dob: Date.new(2009, 7, 15), grade: "10", pos: "Left Field"  },
  { email: "sam.t@ahs.student.edu",    first: "Sam",    last: "Truong",    dob: Date.new(2010, 4,  8), grade: "9",  pos: "Second Base" },
]

baseball_player_users = baseball_athletes.map do |attrs|
  u = User.find_or_create_by!(email: attrs[:email]) do |u2|
    u2.first_name = attrs[:first]; u2.last_name = attrs[:last]; u2.password = "password123"; u2.dob = attrs[:dob]
  end
  SeasonMembership.find_or_create_by!(user: u, season: ahs_baseball_season) do |sm|
    sm.role = :student; sm.grade = attrs[:grade]; sm.level = "varsity"; sm.position = attrs[:pos]
  end
  u
end

baseball_general       = Channel.find_or_create_by!(season: ahs_baseball_season, name: "general") do |c|
  c.created_by = ahs_baseball_coach; c.channel_type = :conversation; c.system_generated = true
end
baseball_announcements = Channel.find_or_create_by!(season: ahs_baseball_season, name: "announcements") do |c|
  c.created_by = ahs_baseball_coach; c.channel_type = :broadcast; c.system_generated = true
end

(baseball_player_users + [ ahs_baseball_coach, ahs_baseball_asst ]).each do |u|
  ChannelMembership.find_or_create_by!(channel: baseball_general,       user: u)
  ChannelMembership.find_or_create_by!(channel: baseball_announcements, user: u)
end
ChannelMembership.find_or_create_by!(channel: baseball_general,       user: ahs_ad)
ChannelMembership.find_or_create_by!(channel: baseball_announcements, user: ahs_ad)

baseball_parent_coaches = Channel.find_or_create_by!(season: ahs_baseball_season, name: "parent-coaches") do |c|
  c.created_by = ahs_baseball_coach; c.channel_type = :family_group; c.system_generated = true
end
[ ahs_baseball_coach, ahs_baseball_asst, ahs_ad ].each { |u| ChannelMembership.find_or_create_by!(channel: baseball_parent_coaches, user: u) }
SeasonMembership.where(season: ahs_baseball_season, role: :parent).includes(:user).each do |sm|
  ChannelMembership.find_or_create_by!(channel: baseball_parent_coaches, user: sm.user)
end

Message.find_or_create_by!(channel: baseball_announcements, sender: ahs_baseball_coach,
  content: "Baseball 2025-26 is underway. First practice March 3 at 3:30pm on the varsity diamond. Come ready to throw.")
Message.find_or_create_by!(channel: baseball_general, sender: User.find_by!(email: "marco.v@ahs.student.edu"),
  content: "Arm is feeling good after winter. Ready to go.")
Message.find_or_create_by!(channel: baseball_general, sender: ahs_baseball_coach,
  content: "Good to hear, Marco. We'll work you in light the first week. Cortez will set the rotation by Friday.")
Message.find_or_create_by!(channel: baseball_general, sender: User.find_by!(email: "derek.o@ahs.student.edu"),
  content: "Coach — are we doing live BP on Monday or just bullpens?")
Message.find_or_create_by!(channel: baseball_general, sender: ahs_baseball_coach,
  content: "Bullpens Monday, live BP Wednesday once I see where arms are at.")

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

bhs_boys_all = [ bhs_swim_coach, head_coach, bhs_swim_student_1, bhs_swim_student_2,
                 james_tran, erik_svensson ] +
               User.where(email: bhs_boys_swim_athletes.map { _1[:email] }).to_a
bhs_boys_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_general, user: u) }
bhs_boys_all.each { |u| ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_announcements, user: u) }
ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_general,       user: bhs_ad)
ChannelMembership.find_or_create_by!(channel: bhs_boys_swim_announcements, user: bhs_ad)

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
ChannelMembership.find_or_create_by!(channel: bhs_girls_general,       user: bhs_ad)
ChannelMembership.find_or_create_by!(channel: bhs_girls_announcements, user: bhs_ad)

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
ChannelMembership.find_or_create_by!(channel: chs_general,       user: chs_ad)
ChannelMembership.find_or_create_by!(channel: chs_announcements, user: chs_ad)

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
ChannelMembership.find_or_create_by!(channel: bhs_bball_general,       user: bhs_ad)
ChannelMembership.find_or_create_by!(channel: bhs_bball_announcements, user: bhs_ad)

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

# ── Audit Log — Safety Activity Events ───────────────────────────────────────
# Simulates the full access/search/exit session history visible in the audit trail.
# Each "session" is three records: safety_accessed → chat_searched → safety_exited.

carlos_m = User.find_by!(email: "carlos.m@bhs.student.edu")

[
  # Session 1: Head coach — routine check on Jordan after conduct flag (15 days ago)
  {
    actor: head_coach, school: ahs, role: "head_coach",
    ago: 15.days, duration: 390, search_reason: nil,
    names: [ "Jordan Lee" ], keyword: nil, found: 12,
    exit_reason: "review_complete"
  },
  # Session 2: Head coach — follow-up search with keyword (5 days ago)
  {
    actor: head_coach, school: ahs, role: "head_coach",
    ago: 5.days, duration: 210, search_reason: nil,
    names: [ "Jordan Lee" ], keyword: "practice", found: 3,
    exit_reason: "review_complete"
  },
  # Session 3: AHS AD — investigated after severe flag; searched two students (3 days ago)
  {
    actor: ahs_ad, school: ahs, role: "athletic_director",
    ago: 3.days, duration: 660, search_reason: nil,
    names: [ "Jordan Lee" ], keyword: "kill", found: 1,
    exit_reason: "review_complete"
  },
  # Session 4: BHS swim coach — checked Marcus Tran after access anomaly (8 days ago)
  {
    actor: bhs_swim_coach, school: bhs, role: "head_coach",
    ago: 8.days, duration: 180, search_reason: nil,
    names: [ "Marcus Tran" ], keyword: nil, found: 7,
    exit_reason: "review_complete"
  },
  # Session 5: BHS AD — reviewed after basketball severity flag (1 day ago)
  {
    actor: bhs_ad, school: bhs, role: "athletic_director",
    ago: 1.day, duration: 295, search_reason: nil,
    names: [ carlos_m.full_name ], keyword: nil, found: 4,
    exit_reason: "review_complete"
  },
  # Session 6: AHS basketball coach — searched with keyword ahead of tournament (12 days ago)
  {
    actor: ahs_basketball_coach, school: ahs, role: "head_coach",
    ago: 12.days, duration: 155, search_reason: nil,
    names: [ "Desmond Carter" ], keyword: "tournament", found: 2,
    exit_reason: "review_complete"
  },
  # Session 7: District admin — cross-school investigation after BHS severity flag (12 hours ago)
  {
    actor: district_admin, school: ahs, role: "district_admin",
    ago: 12.hours, duration: 900, search_reason: nil,
    names: [ "Jordan Lee", "Carlos Mendez" ], keyword: "coach", found: 6,
    exit_reason: "investigation_ongoing"
  },
].each do |s|
  base      = s[:ago].ago
  from_date = 30.days.ago.to_date.to_s
  to_date   = Date.current.to_s
  kw_note   = s[:keyword] ? " | keyword: \"#{s[:keyword]}\"" : ""
  names_str = s[:names].join(", ")

  Activity.find_or_create_by!(event_type: :safety_accessed, actor: s[:actor], school: s[:school],
    occurred_at: base) do |a|
    a.metadata = {
      accessor_role: s[:role],
      notes: "#{s[:actor].full_name} (#{s[:role].titleize} · #{s[:school].name}) opened the student safety chat viewer"
    }
  end

  Activity.find_or_create_by!(event_type: :chat_searched, actor: s[:actor], school: s[:school],
    occurred_at: base + 2.minutes) do |a|
    a.metadata = {
      accessor_role:  s[:role],
      student_names:  s[:names],
      from:           from_date,
      to:             to_date,
      keyword:        s[:keyword],
      found_count:    s[:found],
      notes:          "Searched: #{names_str} | #{from_date}–#{to_date}#{kw_note} | #{s[:found]} message#{"s" unless s[:found] == 1} found"
    }
  end

  Activity.find_or_create_by!(event_type: :safety_exited, actor: s[:actor], school: s[:school],
    occurred_at: base + s[:duration].seconds) do |a|
    mins = s[:duration] / 60
    secs = s[:duration] % 60
    a.metadata = {
      accessor_role:    s[:role],
      reason:           s[:exit_reason],
      duration_seconds: s[:duration],
      notes:            "#{s[:actor].full_name} (#{s[:role].titleize}) exited after #{mins}m #{secs}s"
    }
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

ehs_swim_student = User.find_or_create_by!(email: "priya.k@ehs.student.edu") do |u|
  u.first_name = "Priya"; u.last_name = "Kapoor"; u.password = "password123"; u.dob = Date.new(2008, 9, 5)
end
SeasonMembership.find_or_create_by!(user: ehs_swim_student, season: ehs_swim_season) do |sm|
  sm.role = :student; sm.grade = "11"; sm.level = "varsity"; sm.position = "Backstroke"
end


# ── Pronouns ─────────────────────────────────────────────────────────────────
# Only assign to users who explicitly set them — most leave this blank, which is realistic.

{
  "coach.swim@ahs.edu"          => "he/him",
  "asst.swim@ahs.edu"           => "she/her",
  "ad@ahs.edu"                  => "she/her",
  "student.captain@ahs.student.edu" => "they/them",
  "jordan.lee@ahs.student.edu"  => "she/her",
  "taylor.brooks@ahs.student.edu" => "she/her",
  "ryan.lee@ahs.student.edu"    => "he/him",
  "emma.j@ahs.student.edu"      => "she/her",
  "zoe.m@ahs.student.edu"       => "she/they",
  "maya.j@ahs.student.edu"      => "she/her",
  "zara.a@ahs.student.edu"      => "she/her",
  "amara.o@ahs.student.edu"     => "she/her",
  "coach.bball@ahs.edu"         => "he/him",
  "asst.bball@ahs.edu"          => "she/her",
  "desmond.c@ahs.student.edu"   => "he/him",
  "jaylen.t@ahs.student.edu"    => "they/them",
  "ava.t@bhs.student.edu"       => "she/her",
  "coach.girlsswim@bhs.edu"     => "she/her",
  "olivia.f@chs.student.edu"    => "she/her",
  "priya.k@ehs.student.edu"     => "she/her",
  "ad@rhs.edu"                  => "she/her",
}.each do |email, pronouns|
  User.where(email: email).update_all(pronouns: pronouns)
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

# ── Results from uploaded HY-TEK PDFs ────────────────────────────────────────
# Source: Wave Aquatics HY-TEK Meet Manager 8.0
# School mapping: LW-PN → AHS, BOTH → BHS, EASTL → EHS; external teams use school string labels.

# 12/17/2025 — AHS (LW) vs Sammamish: season opener, home loss 76–109
r7 = MeetResult.create!(
  sport: swimming, home_school: ahs, away_school_name: "Sammamish High School",
  date: "2025-12-17", venue: "AHS Aquatic Center",
  home_score: 76, away_score: 109,
  status: "published", uploaded_by: head_coach,
  ai_summary: "Sammamish opened the season against AHS with a decisive 109–76 road win. Nathan Shaw (SAMM) set the tone with a 21.88 in the 50 Freestyle and Carson Walker added 53.95 in the 100 Butterfly. Walter Keibler swept the IM and 500 Freestyle for Sammamish (2:15.77, 5:27.06). AHS showed individual strength in breaststroke — Matthew Choy and Song Jay finished 1–2 (1:03.80, 1:04.96) — and Ethan Lin posted a 22.14 to finish second in the 50 Free. Sammamish's 400 Free Relay closed in 3:30.36 to seal the final margin.",
  ai_focus: "Relay depth was the decisive gap — Sammamish fielded three competitive relay lineups vs AHS's one. Prioritize relay rotation development before the next dual.",
  events: [
    { "event" => "200 Medley Relay", "results" => [
      { "place" => 1, "athlete" => "SAMM A", "school" => "SAMM", "time" => "1:41.11", "relay_members" => "Shaw R, Keibler, Walker, Shaw N" },
      { "place" => 2, "athlete" => "AHS A",  "school" => "AHS",  "time" => "1:50.96", "relay_members" => "Choundhary, Song, Chachkov, Lin" },
      { "place" => 3, "athlete" => "AHS C",  "school" => "AHS",  "time" => "2:07.73", "relay_members" => "Michelet, Hoener, Tea, Sullivan" } ] },
    { "event" => "200 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Zhao, Aiden",      "school" => "AHS",  "time" => "2:07.16" },
      { "place" => 2, "athlete" => "McGee, Harry",     "school" => "SAMM", "time" => "2:09.08" },
      { "place" => 3, "athlete" => "Crowley, Ian",     "school" => "AHS",  "time" => "2:09.67" },
      { "place" => 4, "athlete" => "Paterson, Kyle",   "school" => "SAMM", "time" => "2:10.11" },
      { "place" => 5, "athlete" => "Gawthrop, Ross",   "school" => "AHS",  "time" => "2:12.08" } ] },
    { "event" => "200 Individual Medley", "results" => [
      { "place" => 1, "athlete" => "Shaw, Ryan",        "school" => "SAMM", "time" => "2:06.39" },
      { "place" => 2, "athlete" => "Keibler, Walter",   "school" => "SAMM", "time" => "2:15.77" },
      { "place" => 3, "athlete" => "Dunsmore, Logan",   "school" => "SAMM", "time" => "2:29.42" },
      { "place" => 4, "athlete" => "Chachkov, Nicholas","school" => "AHS",  "time" => "2:30.95" },
      { "place" => 5, "athlete" => "Sullivan, Rhys",    "school" => "AHS",  "time" => "2:34.65" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Shaw, Nathan",      "school" => "SAMM", "time" => "21.88" },
      { "place" => 2, "athlete" => "Lin, Ethan",        "school" => "AHS",  "time" => "22.14" },
      { "place" => 3, "athlete" => "Whitten, Ben",      "school" => "SAMM", "time" => "23.46" },
      { "place" => 4, "athlete" => "Hoener, Brodie",    "school" => "AHS",  "time" => "26.65" },
      { "place" => 5, "athlete" => "Browder, Harry",    "school" => "SAMM", "time" => "26.80" } ] },
    { "event" => "1 mtr Diving", "results" => [
      { "place" => 1, "athlete" => "Carr, Blake",       "school" => "SAMM", "time" => "170.40" },
      { "place" => 2, "athlete" => "Messier, Jon Grey", "school" => "SAMM", "time" => "118.50" },
      { "place" => 3, "athlete" => "Zur, Yotam",        "school" => "AHS",  "time" => "127.35" },
      { "place" => 4, "athlete" => "Kedar, Daniel",     "school" => "AHS",  "time" => "110.90" },
      { "place" => 5, "athlete" => "Zygiel, Ori",       "school" => "AHS",  "time" => "86.60" } ] },
    { "event" => "100 Butterfly", "results" => [
      { "place" => 1, "athlete" => "Walker, Carson",   "school" => "SAMM", "time" => "53.95" },
      { "place" => 2, "athlete" => "Becciu, Nicholas", "school" => "SAMM", "time" => "1:06.28" },
      { "place" => 3, "athlete" => "Page, Charlie",    "school" => "AHS",  "time" => "1:13.54" },
      { "place" => 4, "athlete" => "Tea, Brendan",     "school" => "AHS",  "time" => "1:14.02" } ] },
    { "event" => "100 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Whitten, Ben",        "school" => "SAMM", "time" => "51.50" },
      { "place" => 2, "athlete" => "Crowley, Ian",        "school" => "AHS",  "time" => "56.56" },
      { "place" => 3, "athlete" => "Hoener, Brodie",      "school" => "AHS",  "time" => "59.31" },
      { "place" => 4, "athlete" => "Zhang, Victor",       "school" => "AHS",  "time" => "59.49" },
      { "place" => 5, "athlete" => "Browder, Harry",      "school" => "SAMM", "time" => "59.51" },
      { "place" => 6, "athlete" => "Chenne, Ethan",       "school" => "SAMM", "time" => "1:00.05" } ] },
    { "event" => "500 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Keibler, Walter",  "school" => "SAMM", "time" => "5:27.06" },
      { "place" => 2, "athlete" => "Lin, Ethan",        "school" => "AHS",  "time" => "5:40.45" },
      { "place" => 3, "athlete" => "Dunsmore, Logan",  "school" => "SAMM", "time" => "6:35.04" },
      { "place" => 4, "athlete" => "Weston, Henry",    "school" => "AHS",  "time" => "7:16.94" } ] },
    { "event" => "200 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "SAMM A", "school" => "SAMM", "time" => "1:38.83", "relay_members" => "Whitten, Chenne, Paterson, Shaw N" },
      { "place" => 2, "athlete" => "AHS A",  "school" => "AHS",  "time" => "1:45.24", "relay_members" => "Hoener, Zhao, Gawthrop, Crowley" },
      { "place" => 3, "athlete" => "SAMM B", "school" => "SAMM", "time" => "1:47.01", "relay_members" => "Carr, Miller, McGee, Becciu" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Walker, Carson",     "school" => "SAMM", "time" => "57.09" },
      { "place" => 2, "athlete" => "Shaw, Ryan",         "school" => "SAMM", "time" => "1:00.28" },
      { "place" => 3, "athlete" => "Choy, Matthew",      "school" => "AHS",  "time" => "1:11.01" },
      { "place" => 4, "athlete" => "Beckmann, Kurtis",   "school" => "AHS",  "time" => "1:13.35" },
      { "place" => 5, "athlete" => "Michelet, Alexandre","school" => "AHS",  "time" => "1:15.36" } ] },
    { "event" => "100 Breaststroke", "results" => [
      { "place" => 1, "athlete" => "Choy, Matthew",    "school" => "AHS",  "time" => "1:03.80" },
      { "place" => 2, "athlete" => "Song, Jay",         "school" => "AHS",  "time" => "1:04.96" },
      { "place" => 3, "athlete" => "Shaw, Nathan",      "school" => "SAMM", "time" => "1:05.04" },
      { "place" => 4, "athlete" => "Chenne, Ethan",     "school" => "SAMM", "time" => "1:11.65" },
      { "place" => 5, "athlete" => "Becciu, Nicholas",  "school" => "SAMM", "time" => "1:15.18" },
      { "place" => 6, "athlete" => "Zhao, Aiden",       "school" => "AHS",  "time" => "1:15.40" } ] },
    { "event" => "400 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "SAMM A", "school" => "SAMM", "time" => "3:30.36", "relay_members" => "Shaw R, Keibler, Whitten, Walker" },
      { "place" => 2, "athlete" => "SAMM B", "school" => "SAMM", "time" => "3:56.36", "relay_members" => "Browder, McGee, Ferguson, Dunsmore" },
      { "place" => 3, "athlete" => "AHS A",  "school" => "AHS",  "time" => "4:05.14", "relay_members" => "Choundhary, Chachkov, Zhao, Crowley" },
      { "place" => 4, "athlete" => "SAMM C", "school" => "SAMM", "time" => "4:24.00", "relay_members" => "Martin K, Miller, Carr, Paterson" },
      { "place" => 5, "athlete" => "AHS C",  "school" => "AHS",  "time" => "4:37.37", "relay_members" => "Beckmann, Page, Geels, Fithian" } ] },
  ]
)
r7.ai_standouts = [
  "Nathan Shaw (SAMM) — 50 Free: 21.88 · Meet best",
  "Walter Keibler (SAMM) — 200 IM: 2:15.77 / 500 Free: 5:27.06 · Dual sweep",
  "Matthew Choy (AHS) — 100 Breast: 1:03.80 / 100 Back: 1:11.01 · Top AHS scorer",
  "Ethan Lin (AHS) — 50 Free: 22.14 / 500 Free: 5:40.45",
]
r7.save!

# 12/17/2025 — EHS vs Juanita: dominant season opener, 121–59
r8 = MeetResult.create!(
  sport: ehs_girls_swimming, home_school: ehs, away_school_name: "Juanita High School",
  date: "2025-12-17", venue: "Eastlake Aquatic Center",
  home_score: 121, away_score: 59,
  status: "published", uploaded_by: ehs_swim_coach,
  ai_summary: "Eastlake opened the season with a dominant 121–59 dual win over Juanita. Adam Cao swept the 100 Butterfly (55.72) and 200 IM (2:08.32), and anchored the 400 Free Relay (3:38.27). Ender Ramsby set a season-best 56.80 in the 100 Backstroke. Pranag Ambekar (EHS) won the 200 Freestyle at 2:02.49 and contributed to two relay wins. Makar Shnitko scored 289.40 in diving — the highest individual diving score in the district so far this season. For Juanita, Dario Giuliani (2:19.32, 200 IM) and Caden Gray (1:05.52, 100 Fly) were the bright spots.",
  ai_focus: "EHS breaststroke had a thin scoring margin vs Juanita — only two scorers. Worth building depth there before KingCo.",
  events: [
    { "event" => "200 Medley Relay", "results" => [
      { "place" => 1, "athlete" => "EHS A",  "school" => "EHS",  "time" => "1:45.52", "relay_members" => "Ramsby, Rawal, Cao, Martin" },
      { "place" => 2, "athlete" => "JUAN A", "school" => "JUAN", "time" => "1:56.68", "relay_members" => "Entman, Gray, Acharya, Giuliani" },
      { "place" => 3, "athlete" => "EHS B",  "school" => "EHS",  "time" => "1:57.72", "relay_members" => "Villanueva C, Chow, Stuart, Chen B" },
      { "place" => 4, "athlete" => "JUAN B", "school" => "JUAN", "time" => "2:09.53", "relay_members" => "Kong, Rydell, Hein, Orswell" },
      { "place" => 5, "athlete" => "EHS C",  "school" => "EHS",  "time" => "2:16.46", "relay_members" => "Hodges, Rohit, Agnihotri, Karthikeyan" } ] },
    { "event" => "200 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Ambekar, Pranag",    "school" => "EHS",  "time" => "2:02.49" },
      { "place" => 2, "athlete" => "Francis, Will",      "school" => "EHS",  "time" => "2:05.98" },
      { "place" => 3, "athlete" => "Villanueva, Paolo",  "school" => "EHS",  "time" => "2:10.60" },
      { "place" => 4, "athlete" => "Rydell, Zavier",     "school" => "JUAN", "time" => "2:23.22" },
      { "place" => 5, "athlete" => "Orswell, Jacob",     "school" => "JUAN", "time" => "2:25.69" } ] },
    { "event" => "200 Individual Medley", "results" => [
      { "place" => 1, "athlete" => "Cao, Adam",       "school" => "EHS",  "time" => "2:08.32" },
      { "place" => 2, "athlete" => "Giuliani, Dario", "school" => "JUAN", "time" => "2:19.32" },
      { "place" => 3, "athlete" => "Martin, Grayson", "school" => "EHS",  "time" => "2:20.14" },
      { "place" => 4, "athlete" => "Rotkin, Max",     "school" => "EHS",  "time" => "2:31.35" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Rawal, Neil",         "school" => "EHS",  "time" => "24.83" },
      { "place" => 2, "athlete" => "Sriram, Pranay",      "school" => "EHS",  "time" => "25.37" },
      { "place" => 3, "athlete" => "Villanueva, Carlo",   "school" => "EHS",  "time" => "26.48" },
      { "place" => 4, "athlete" => "Orswell, Jacob",      "school" => "JUAN", "time" => "27.57" },
      { "place" => 5, "athlete" => "Bhargava, Saarth",    "school" => "JUAN", "time" => "29.18" } ] },
    { "event" => "1 mtr Diving", "results" => [
      { "place" => 1, "athlete" => "Shnitko, Makar",  "school" => "EHS",  "time" => "289.40" },
      { "place" => 2, "athlete" => "Sather, Markus",  "school" => "JUAN", "time" => "160.80" },
      { "place" => 3, "athlete" => "Schatz, Blake",   "school" => "JUAN", "time" => "118.45" } ] },
    { "event" => "100 Butterfly", "results" => [
      { "place" => 1, "athlete" => "Cao, Adam",       "school" => "EHS",  "time" => "55.72" },
      { "place" => 2, "athlete" => "Gray, Caden",     "school" => "JUAN", "time" => "1:05.52" },
      { "place" => 3, "athlete" => "Rydell, Zavier",  "school" => "JUAN", "time" => "1:05.76" },
      { "place" => 4, "athlete" => "Rotkin, Max",     "school" => "EHS",  "time" => "1:07.68" },
      { "place" => 5, "athlete" => "Stuart, Aiden",   "school" => "EHS",  "time" => "1:08.80" } ] },
    { "event" => "100 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Ambekar, Pranag", "school" => "EHS",  "time" => "57.80" },
      { "place" => 2, "athlete" => "Kong, Jonathan",  "school" => "JUAN", "time" => "1:04.20" },
      { "place" => 3, "athlete" => "Entman, Cory",    "school" => "JUAN", "time" => "1:05.51" },
      { "place" => 4, "athlete" => "Bhargava, Saarth","school" => "JUAN", "time" => "1:07.96" } ] },
    { "event" => "500 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Francis, Will",   "school" => "EHS",  "time" => "5:55.24" },
      { "place" => 2, "athlete" => "Sriram, Pranay",  "school" => "EHS",  "time" => "6:10.34" },
      { "place" => 3, "athlete" => "Acharya, Barun",  "school" => "JUAN", "time" => "6:53.47" },
      { "place" => 4, "athlete" => "Fiala, Lincoln",  "school" => "JUAN", "time" => "8:23.53" } ] },
    { "event" => "200 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "EHS A",  "school" => "EHS",  "time" => "1:43.43", "relay_members" => "Rawal, Rotkin, Ambekar, Sriram" },
      { "place" => 2, "athlete" => "JUAN A", "school" => "JUAN", "time" => "1:44.47", "relay_members" => "Acharya, Kong, Entman, Gray" },
      { "place" => 3, "athlete" => "EHS B",  "school" => "EHS",  "time" => "1:47.30", "relay_members" => "Villanueva P, Chow, Hodges, Francis" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Ramsby, Ender",    "school" => "EHS",  "time" => "56.80", "personal_best" => true },
      { "place" => 2, "athlete" => "Martin, Grayson",  "school" => "EHS",  "time" => "1:05.04" },
      { "place" => 3, "athlete" => "Giuliani, Dario",  "school" => "JUAN", "time" => "1:07.89" },
      { "place" => 4, "athlete" => "Villanueva, Paolo","school" => "EHS",  "time" => "1:11.25" },
      { "place" => 5, "athlete" => "Kong, Jonathan",   "school" => "JUAN", "time" => "1:16.22" } ] },
    { "event" => "100 Breaststroke", "results" => [
      { "place" => 1, "athlete" => "Rawal, Neil",    "school" => "EHS",  "time" => "1:09.37" },
      { "place" => 2, "athlete" => "Acharya, Barun", "school" => "JUAN", "time" => "1:11.03" },
      { "place" => 3, "athlete" => "Chow, Ian",      "school" => "EHS",  "time" => "1:11.94" },
      { "place" => 4, "athlete" => "Rohit, Adit",    "school" => "EHS",  "time" => "1:13.76" },
      { "place" => 5, "athlete" => "Entman, Cory",   "school" => "JUAN", "time" => "1:16.54" } ] },
    { "event" => "400 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "EHS A",  "school" => "EHS",  "time" => "3:38.27", "relay_members" => "Ramsby, Cao, Martin, Sriram" },
      { "place" => 2, "athlete" => "EHS B",  "school" => "EHS",  "time" => "3:57.47", "relay_members" => "Francis, Rotkin, Ambekar, Villanueva P" },
      { "place" => 3, "athlete" => "JUAN A", "school" => "JUAN", "time" => "4:20.62", "relay_members" => "Fiala, Bhargava, Rydell, Giuliani" },
      { "place" => 4, "athlete" => "EHS C",  "school" => "EHS",  "time" => "4:15.21", "relay_members" => "Pendse, Stuart, Rohit, Villanueva C" } ] },
  ]
)
r8.ai_standouts = [
  "Adam Cao (EHS) — 200 IM: 2:08.32 / 100 Fly: 55.72 · IM-Fly double",
  "Ender Ramsby (EHS) — 100 Back: 56.80 · Season best",
  "Makar Shnitko (EHS) — Diving: 289.40 · District high score",
  "Pranag Ambekar (EHS) — 200 Free: 2:02.49 / 100 Free: 57.80 · Freestyle double",
]
r8.save!

# 1/7/2026 — AHS (LW) vs EHS (EASTL): narrow home win, 93–91
r9 = MeetResult.create!(
  sport: swimming, home_school: ahs, away_school: ehs,
  date: "2026-01-07", venue: "AHS Aquatic Center",
  home_score: 93, away_score: 91,
  status: "published", uploaded_by: head_coach,
  ai_summary: "The closest dual meet of the season — AHS edged Eastlake 93–91 on a late relay swing. Jacob Lee (AHS) was the individual standout, winning the 200 Freestyle (1:43.89) and 100 Butterfly (53.78) back-to-back for 10 points. Makar Shnitko's 304.80 diving score (6 pts) gave EHS a crucial early lead that lasted until the final relay. Justin Brown (EHS) won the 50 Freestyle (21.47) and 100 Breaststroke (57.40) — a sprint-breast double that contributed 10 EHS points. AHS's 400 Free Relay (3:16.92) ultimately provided the decisive margin over EHS's 3:26.01.",
  ai_focus: "Butterfly depth beyond Lee remains thin — two EHS swimmers scored without AHS answer in that event. Develop backup 100 Fly roster before KingCo.",
  events: [
    { "event" => "200 Medley Relay", "results" => [
      { "place" => 1, "athlete" => "EHS A", "school" => "EHS", "time" => "1:41.78", "relay_members" => "Ramsby, Brown, Cao, Martin" },
      { "place" => 2, "athlete" => "AHS A", "school" => "AHS", "time" => "1:49.76", "relay_members" => "Chachkov, Fithian, Kedar, Crowley" },
      { "place" => 3, "athlete" => "EHS B", "school" => "EHS", "time" => "1:56.56", "relay_members" => "Sriram, Chow, Mansour, Rotkin" },
      { "place" => 4, "athlete" => "EHS C", "school" => "EHS", "time" => "1:58.11", "relay_members" => "Francis, Chen B, Stuart, Ambekar" },
      { "place" => 5, "athlete" => "AHS B", "school" => "AHS", "time" => "2:04.07", "relay_members" => "Gawthrop, Zhang, Tea, Hoener" } ] },
    { "event" => "200 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Lee, Jacob",       "school" => "AHS", "time" => "1:43.89", "personal_best" => true },
      { "place" => 2, "athlete" => "Ramsby, Ender",    "school" => "EHS", "time" => "1:49.31" },
      { "place" => 3, "athlete" => "Choundhary, Nakul","school" => "AHS", "time" => "2:04.68" },
      { "place" => 4, "athlete" => "Martin, Grayson",  "school" => "EHS", "time" => "2:08.32" },
      { "place" => 5, "athlete" => "Zhang, Victor",    "school" => "AHS", "time" => "2:13.53" },
      { "place" => 6, "athlete" => "Mansour, Yousef",  "school" => "EHS", "time" => "2:14.60" } ] },
    { "event" => "200 Individual Medley", "results" => [
      { "place" => 1, "athlete" => "Chen, Cedric",    "school" => "AHS", "time" => "2:05.22" },
      { "place" => 2, "athlete" => "Cao, Adam",       "school" => "EHS", "time" => "2:11.77" },
      { "place" => 3, "athlete" => "Francis, Will",   "school" => "EHS", "time" => "2:24.64" },
      { "place" => 4, "athlete" => "Ambekar, Pranag", "school" => "EHS", "time" => "2:26.93" },
      { "place" => 5, "athlete" => "Nelson, Maxwell", "school" => "AHS", "time" => "2:49.73" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Brown, Justin",      "school" => "EHS", "time" => "21.47" },
      { "place" => 2, "athlete" => "Hammer, Maximillian","school" => "AHS", "time" => "23.30" },
      { "place" => 3, "athlete" => "Crowley, Ian",       "school" => "AHS", "time" => "23.68" },
      { "place" => 4, "athlete" => "Martin, Grayson",    "school" => "EHS", "time" => "24.29" },
      { "place" => 5, "athlete" => "Rawal, Neil",        "school" => "EHS", "time" => "25.27" },
      { "place" => 6, "athlete" => "Choundhary, Nakul",  "school" => "AHS", "time" => "25.31" } ] },
    { "event" => "1 mtr Diving", "results" => [
      { "place" => 1, "athlete" => "Shnitko, Makar", "school" => "EHS", "time" => "304.80" },
      { "place" => 2, "athlete" => "Kedar, Daniel",  "school" => "AHS", "time" => "140.65" },
      { "place" => 3, "athlete" => "Zur, Yotam",     "school" => "AHS", "time" => "111.85" },
      { "place" => 4, "athlete" => "Amitay, Noam",   "school" => "AHS", "time" => "107.05" } ] },
    { "event" => "100 Butterfly", "results" => [
      { "place" => 1, "athlete" => "Lee, Jacob",          "school" => "AHS", "time" => "53.78", "personal_best" => true },
      { "place" => 2, "athlete" => "Chen, Cedric",        "school" => "AHS", "time" => "54.16" },
      { "place" => 3, "athlete" => "Hammer, Maximillian", "school" => "AHS", "time" => "55.75" },
      { "place" => 4, "athlete" => "Rotkin, Max",         "school" => "EHS", "time" => "1:05.94" },
      { "place" => 5, "athlete" => "Stuart, Aiden",       "school" => "EHS", "time" => "1:09.78" },
      { "place" => 6, "athlete" => "Chen, Byron",         "school" => "EHS", "time" => "1:12.20" } ] },
    { "event" => "100 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Cao, Adam",         "school" => "EHS", "time" => "53.39" },
      { "place" => 2, "athlete" => "Sriram, Pranay",    "school" => "EHS", "time" => "55.20" },
      { "place" => 3, "athlete" => "Gawthrop, Ross",    "school" => "AHS", "time" => "57.91" },
      { "place" => 4, "athlete" => "Hoener, Brodie",    "school" => "AHS", "time" => "57.99" },
      { "place" => 5, "athlete" => "Chachkov, Nicholas","school" => "AHS", "time" => "58.65" },
      { "place" => 6, "athlete" => "Rawal, Neil",       "school" => "EHS", "time" => "58.68" } ] },
    { "event" => "500 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Ramsby, Ender",  "school" => "EHS", "time" => "4:54.35" },
      { "place" => 2, "athlete" => "Rotkin, Max",    "school" => "EHS", "time" => "5:44.80" },
      { "place" => 3, "athlete" => "Francis, Will",  "school" => "EHS", "time" => "5:51.38" },
      { "place" => 4, "athlete" => "Tea, Brendan",   "school" => "AHS", "time" => "7:25.77" } ] },
    { "event" => "200 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "AHS A", "school" => "AHS", "time" => "1:31.23", "relay_members" => "Lee, Hammer, Chen C, Lin" },
      { "place" => 2, "athlete" => "EHS A", "school" => "EHS", "time" => "1:45.52", "relay_members" => "Hodges, Chow, Ambekar, Rawal" },
      { "place" => 3, "athlete" => "AHS B", "school" => "AHS", "time" => "1:45.66", "relay_members" => "Chachkov, Beckmann, Zhang, Nelson" },
      { "place" => 4, "athlete" => "EHS B", "school" => "EHS", "time" => "1:50.73", "relay_members" => "Chen B, Rohit, Pendse, Francis" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Lin, Ethan",      "school" => "AHS", "time" => "1:04.42" },
      { "place" => 2, "athlete" => "Mansour, Yousef", "school" => "EHS", "time" => "1:05.86" },
      { "place" => 3, "athlete" => "Sriram, Pranay",  "school" => "EHS", "time" => "1:09.88" },
      { "place" => 4, "athlete" => "Rohit, Adit",     "school" => "EHS", "time" => "1:20.08" },
      { "place" => 5, "athlete" => "Scott, William",  "school" => "AHS", "time" => "1:23.72" } ] },
    { "event" => "100 Breaststroke", "results" => [
      { "place" => 1, "athlete" => "Brown, Justin",   "school" => "EHS", "time" => "57.40" },
      { "place" => 2, "athlete" => "Lin, Ethan",      "school" => "AHS", "time" => "1:03.87" },
      { "place" => 3, "athlete" => "Fithian, Jack",   "school" => "AHS", "time" => "1:10.78" },
      { "place" => 4, "athlete" => "Chow, Ian",       "school" => "EHS", "time" => "1:12.08" },
      { "place" => 5, "athlete" => "Zhang, Victor",   "school" => "AHS", "time" => "1:13.45" },
      { "place" => 6, "athlete" => "Ambekar, Pranag", "school" => "EHS", "time" => "1:14.47" } ] },
    { "event" => "400 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "AHS A", "school" => "AHS", "time" => "3:16.92", "relay_members" => "Lee, Hammer, Chen C, Lin", "personal_best" => true },
      { "place" => 2, "athlete" => "EHS A", "school" => "EHS", "time" => "3:26.01", "relay_members" => "Ramsby, Cao, Martin, Brown" },
      { "place" => 3, "athlete" => "EHS B", "school" => "EHS", "time" => "3:48.87", "relay_members" => "Rawal, Rotkin, Sriram, Mansour" },
      { "place" => 4, "athlete" => "AHS C", "school" => "AHS", "time" => "3:54.89", "relay_members" => "Crowley, Hoener, Choundhary, Cheng" } ] },
  ]
)
r9.ai_standouts = [
  "Jacob Lee (AHS) — 200 Free: 1:43.89 (PR) / 100 Fly: 53.78 (PR) · Season sweep",
  "Justin Brown (EHS) — 50 Free: 21.47 / 100 Breast: 57.40 · Sprint-breast double",
  "Makar Shnitko (EHS) — Diving: 304.80 · Season high",
  "400 Free Relay (AHS) — 3:16.92 · Meet-winning relay · Season PR",
]
r9.save!

# 1/7/2026 — BHS (BOTH) vs Inglemoor: home win, 92–75
r10 = MeetResult.create!(
  sport: bhs_boys_swimming, home_school: bhs, away_school_name: "Inglemoor High School",
  date: "2026-01-07", venue: "BHS Natatorium",
  home_score: 92, away_score: 75,
  status: "published", uploaded_by: bhs_swim_coach,
  ai_summary: "BHS won a home dual over Inglemoor, 92–75, in a meet that featured quality distance and IM racing. Roman Byelykh swept the 200 Freestyle (1:54.71) and 500 Freestyle (5:03.59) for BHS. Sergey Zaporozhets added a 2:07.71 in the 200 IM. Edi Vasilescu posted the meet's best backstroke split at 59.71. Inglemoor's Ethan Na was the visiting team's standout, winning the 100 Breaststroke (1:08.66) and placing in the 200 Freestyle (2:05.81). West Replogle (INGL) edged Vasilescu in the 50 Freestyle 24.32–24.93. BHS's 400 Free Relay (3:33.17) sealed the result.",
  ai_focus: "BHS butterfly depth provided scoring cushion — Sun and Zaporozhets scored 1–2. Build on that heading into the KingCo qualifier.",
  events: [
    { "event" => "200 Medley Relay", "results" => [
      { "place" => 1, "athlete" => "BHS A",  "school" => "BHS",  "time" => "1:50.36", "relay_members" => "Vasilescu, Sun, Byelykh, Zaporozhets" },
      { "place" => 2, "athlete" => "INGL A", "school" => "INGL", "time" => "1:54.03", "relay_members" => "Replogle W, Zeng, King, Aleksandrov" } ] },
    { "event" => "200 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Byelykh, Roman",   "school" => "BHS",  "time" => "1:54.71" },
      { "place" => 2, "athlete" => "Na, Ethan",         "school" => "INGL", "time" => "2:05.81" },
      { "place" => 3, "athlete" => "Berrios, Gabriel",  "school" => "BHS",  "time" => "2:41.61" },
      { "place" => 4, "athlete" => "Hooda, Dhruv",      "school" => "BHS",  "time" => "2:53.81" },
      { "place" => 5, "athlete" => "Hughes, Elliot",    "school" => "INGL", "time" => "3:36.67" } ] },
    { "event" => "200 Individual Medley", "results" => [
      { "place" => 1, "athlete" => "Zaporozhets, Sergey","school" => "BHS",  "time" => "2:07.71" },
      { "place" => 2, "athlete" => "King, Marcos",        "school" => "INGL", "time" => "2:21.31" },
      { "place" => 3, "athlete" => "Adante, Victor",      "school" => "BHS",  "time" => "2:41.52" } ] },
    { "event" => "50 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Replogle, West",     "school" => "INGL", "time" => "24.32" },
      { "place" => 2, "athlete" => "Vasilescu, Edi",     "school" => "BHS",  "time" => "24.93" },
      { "place" => 3, "athlete" => "Aleksandrov, Adrian","school" => "INGL", "time" => "25.72" },
      { "place" => 4, "athlete" => "Berrios, Gabriel",   "school" => "BHS",  "time" => "29.10" },
      { "place" => 5, "athlete" => "Schmoll, Hunter",    "school" => "BHS",  "time" => "30.35" },
      { "place" => 6, "athlete" => "Gunderson, David",   "school" => "INGL", "time" => "30.96" } ] },
    { "event" => "100 Butterfly", "results" => [
      { "place" => 1, "athlete" => "Sun, Jesse",          "school" => "BHS",  "time" => "59.25" },
      { "place" => 2, "athlete" => "Zaporozhets, Sergey", "school" => "BHS",  "time" => "59.76" },
      { "place" => 3, "athlete" => "O'Farrell, Mason",    "school" => "BHS",  "time" => "1:04.63" },
      { "place" => 4, "athlete" => "Zeng, Zachary",       "school" => "INGL", "time" => "1:10.63" } ] },
    { "event" => "100 Freestyle", "results" => [
      { "place" => 1, "athlete" => "LaMaster, Noah",  "school" => "BHS",  "time" => "59.35" },
      { "place" => 2, "athlete" => "Adante, Victor",  "school" => "BHS",  "time" => "1:02.09" },
      { "place" => 3, "athlete" => "Cohen, Alex",     "school" => "INGL", "time" => "1:05.09" },
      { "place" => 4, "athlete" => "Speed, Rylan",    "school" => "INGL", "time" => "1:05.10" },
      { "place" => 5, "athlete" => "Gillen, John",    "school" => "INGL", "time" => "1:07.10" },
      { "place" => 6, "athlete" => "Schmoll, Hunter", "school" => "BHS",  "time" => "1:12.53" } ] },
    { "event" => "500 Freestyle", "results" => [
      { "place" => 1, "athlete" => "Byelykh, Roman",      "school" => "BHS",  "time" => "5:03.59" },
      { "place" => 2, "athlete" => "Rader, Lawson",        "school" => "INGL", "time" => "5:39.33" },
      { "place" => 3, "athlete" => "Aleksandrov, Adrian",  "school" => "INGL", "time" => "6:39.29" },
      { "place" => 4, "athlete" => "Brooks, Quinten",      "school" => "BHS",  "time" => "7:22.85" },
      { "place" => 5, "athlete" => "Smith, Anderson",      "school" => "BHS",  "time" => "8:48.65" } ] },
    { "event" => "200 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "BHS A",  "school" => "BHS",  "time" => "1:48.25", "relay_members" => "Adante, Anderson, LaMaster, O'Farrell" },
      { "place" => 2, "athlete" => "INGL A", "school" => "INGL", "time" => "1:56.26", "relay_members" => "Gunderson, Replogle D, Simard, Speed" },
      { "place" => 3, "athlete" => "BHS B",  "school" => "BHS",  "time" => "2:08.05", "relay_members" => "Berrios, Brooks, Hooda, Schmoll" } ] },
    { "event" => "100 Backstroke", "results" => [
      { "place" => 1, "athlete" => "Vasilescu, Edi",  "school" => "BHS",  "time" => "59.71" },
      { "place" => 2, "athlete" => "Replogle, West",  "school" => "INGL", "time" => "1:03.05" },
      { "place" => 3, "athlete" => "O'Farrell, Mason","school" => "BHS",  "time" => "1:07.97" },
      { "place" => 4, "athlete" => "Zeng, Zachary",   "school" => "INGL", "time" => "1:12.51" },
      { "place" => 5, "athlete" => "Gillen, John",    "school" => "INGL", "time" => "1:17.08" },
      { "place" => 6, "athlete" => "Brooks, Quinten", "school" => "BHS",  "time" => "1:23.41" } ] },
    { "event" => "100 Breaststroke", "results" => [
      { "place" => 1, "athlete" => "Na, Ethan",         "school" => "INGL", "time" => "1:08.66" },
      { "place" => 2, "athlete" => "Sun, Jesse",         "school" => "BHS",  "time" => "1:10.88" },
      { "place" => 3, "athlete" => "LaMaster, Noah",    "school" => "BHS",  "time" => "1:17.26" },
      { "place" => 4, "athlete" => "Simard, Alexander", "school" => "INGL", "time" => "1:24.27" },
      { "place" => 5, "athlete" => "Hooda, Dhruv",      "school" => "BHS",  "time" => "1:25.42" },
      { "place" => 6, "athlete" => "Cohen, Alex",       "school" => "INGL", "time" => "1:31.00" } ] },
    { "event" => "400 Freestyle Relay", "results" => [
      { "place" => 1, "athlete" => "BHS A",  "school" => "BHS",  "time" => "3:33.17", "relay_members" => "Sun, Vasilescu, Byelykh, Zaporozhets" },
      { "place" => 2, "athlete" => "INGL A", "school" => "INGL", "time" => "3:53.94", "relay_members" => "Na, Aleksandrov, Replogle W, Rader" },
      { "place" => 3, "athlete" => "INGL B", "school" => "INGL", "time" => "4:21.96", "relay_members" => "Gillen, Replogle D, Speed, Zeng" },
      { "place" => 4, "athlete" => "BHS B",  "school" => "BHS",  "time" => "5:22.01", "relay_members" => "Brooks, Israel, Schmoll, Smith" } ] },
  ]
)
r10.ai_standouts = [
  "Roman Byelykh (BHS) — 200 Free: 1:54.71 / 500 Free: 5:03.59 · Distance double",
  "Edi Vasilescu (BHS) — 100 Back: 59.71 / 50 Free: 24.93 · Sprint-back double",
  "Sergey Zaporozhets (BHS) — 200 IM: 2:07.71 / 100 Fly: 59.76",
  "Ethan Na (INGL) — 100 Breast: 1:08.66 · Top Inglemoor scorer",
]
r10.save!

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

# ── Ridgecrest School District ───────────────────────────────────────────────
# Chris Nguyen (AHS head coach) also coaches girls swimming here — cross-district
# linked account so the district switcher appears in the demo.

rcsd = District.find_or_create_by!(name: "Ridgecrest School District") do |d|
  d.city    = "Bellevue"
  d.state   = "WA"
  d.country = "US"
  d.active  = true
end

rhs = School.find_or_create_by!(name: "Ridgecrest High School", district: rcsd) do |s|
  s.city   = "Bellevue"
  s.state  = "WA"
  s.active = true
end

rhs_ad = User.find_or_create_by!(email: "ad@rhs.edu") do |u|
  u.first_name = "Patricia"
  u.last_name  = "Kim"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: rhs_ad, role: :athletic_director, school: rhs) { |r| r.start_date = Date.current }

rhs_asst_coach = User.find_or_create_by!(email: "asst.swim@rhs.edu") do |u|
  u.first_name = "Diane"
  u.last_name  = "Alvarez"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: rhs_asst_coach, role: :head_coach, school: rhs) { |r| r.start_date = Date.current }

rhs_swim_template = SportTemplate.find_or_initialize_by(district: rcsd, name: "Swimming")
rhs_swim_template.assign_attributes(athletic_season: :winter, gender_config: :separate, active: true)
rhs_swim_template.save!

rhs_girls_swimming = Sport.find_or_create_by!(sport_template: rhs_swim_template, school: rhs, gender: :girls) do |s|
  s.sport_type = "swimming"
  s.status     = :active
end

rhs_swim_season = Season.find_or_create_by!(sport: rhs_girls_swimming, school_year: "2025-26") do |s|
  s.name      = "Girls Swimming RHS 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 2, 28)
  s.status    = :active
end

SeasonMembership.find_or_create_by!(user: rhs_asst_coach, season: rhs_swim_season) { |sm| sm.role = :head_coach }

rhs_student_1 = User.find_or_create_by!(email: "zoe.park@rhs.student.edu") do |u|
  u.first_name = "Zoe"; u.last_name = "Park"; u.password = "password123"
end
rhs_student_2 = User.find_or_create_by!(email: "nina.choi@rhs.student.edu") do |u|
  u.first_name = "Nina"; u.last_name = "Choi"; u.password = "password123"
end
rhs_student_3 = User.find_or_create_by!(email: "aria.patel@rhs.student.edu") do |u|
  u.first_name = "Aria"; u.last_name = "Patel"; u.password = "password123"
end
rhs_parent_1 = User.find_or_create_by!(email: "jenny.park@example.com") do |u|
  u.first_name = "Jenny"; u.last_name = "Park"; u.password = "password123"
end
rhs_parent_2 = User.find_or_create_by!(email: "raj.patel@example.com") do |u|
  u.first_name = "Raj"; u.last_name = "Patel"; u.password = "password123"
end

[ rhs_student_1, rhs_student_2, rhs_student_3 ].each do |s|
  SeasonMembership.find_or_create_by!(user: s, season: rhs_swim_season) { |sm| sm.role = :student }
end
[ rhs_parent_1, rhs_parent_2 ].each do |p|
  SeasonMembership.find_or_create_by!(user: p, season: rhs_swim_season) { |sm| sm.role = :parent }
end

ParentStudentRelationship.find_or_create_by!(parent: rhs_parent_1, student: rhs_student_1)
ParentStudentRelationship.find_or_create_by!(parent: rhs_parent_2, student: rhs_student_3)

rhs_general = Channel.find_or_create_by!(season: rhs_swim_season, name: "general") do |c|
  c.created_by = rhs_asst_coach; c.channel_type = :conversation; c.system_generated = true; c.active = true
end
rhs_announcements = Channel.find_or_create_by!(season: rhs_swim_season, name: "announcements") do |c|
  c.created_by = rhs_asst_coach; c.channel_type = :broadcast; c.system_generated = true; c.active = true
end

[
  rhs_asst_coach, rhs_ad,
  rhs_student_1, rhs_student_2, rhs_student_3, rhs_parent_1, rhs_parent_2,
].each do |u|
  ChannelMembership.find_or_create_by!(channel: rhs_general,       user: u)
  ChannelMembership.find_or_create_by!(channel: rhs_announcements, user: u)
end

Message.find_or_create_by!(channel: rhs_announcements, sender: rhs_asst_coach,
  content: "Welcome to Girls Swimming at Ridgecrest! Practice starts Monday at 4pm.") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: rhs_general, sender: rhs_student_1,
  content: "Thanks Coach! Super excited for the season.") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: rhs_general, sender: rhs_student_2,
  content: "What do we need to bring to the first practice?") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: rhs_general, sender: rhs_asst_coach,
  content: "Bring your team suit, cap, and goggles. We'll review time standards this week.") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: rhs_general, sender: rhs_student_3,
  content: "See you all Monday!") { |m| m.flag_action = nil }

# ── Valley Unified School District ───────────────────────────────────────────

vusd = District.find_or_create_by!(name: "Valley Unified School District") do |d|
  d.city    = "Kirkland"
  d.state   = "WA"
  d.country = "US"
  d.active  = true
end

vhs = School.find_or_create_by!(name: "Valley High School", district: vusd) do |s|
  s.city   = "Kirkland"
  s.state  = "WA"
  s.active = true
end

vhs_ad = User.find_or_create_by!(email: "ad@vhs.edu") do |u|
  u.first_name = "Marcus"
  u.last_name  = "Webb"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: vhs_ad, role: :athletic_director, school: vhs) { |r| r.start_date = Date.current }

vhs_head_coach = User.find_or_create_by!(email: "coach.swim@vhs.edu") do |u|
  u.first_name = "Sofia"
  u.last_name  = "Mendez"
  u.password   = "password123"
end
InstitutionRole.find_or_create_by!(user: vhs_head_coach, role: :head_coach, school: vhs) { |r| r.start_date = Date.current }

vusd_swim_template = SportTemplate.find_or_initialize_by(district: vusd, name: "Swimming")
vusd_swim_template.assign_attributes(athletic_season: :winter, gender_config: :separate, active: true)
vusd_swim_template.save!

vhs_boys_swimming = Sport.find_or_create_by!(sport_template: vusd_swim_template, school: vhs, gender: :boys) do |s|
  s.sport_type = "swimming"
  s.status     = :active
end

vhs_swim_season = Season.find_or_create_by!(sport: vhs_boys_swimming, school_year: "2025-26") do |s|
  s.name      = "Boys Swimming Valley 2025-26"
  s.starts_at = Date.new(2025, 12, 1)
  s.ends_at   = Date.new(2026, 2, 28)
  s.status    = :active
end

SeasonMembership.find_or_create_by!(user: vhs_head_coach, season: vhs_swim_season) { |sm| sm.role = :head_coach }

vhs_student_1 = User.find_or_create_by!(email: "tyler.webb@vhs.student.edu") do |u|
  u.first_name = "Tyler"; u.last_name = "Webb"; u.password = "password123"
end
vhs_student_2 = User.find_or_create_by!(email: "omar.hassan@vhs.student.edu") do |u|
  u.first_name = "Omar"; u.last_name = "Hassan"; u.password = "password123"
end
vhs_student_3 = User.find_or_create_by!(email: "jake.russo@vhs.student.edu") do |u|
  u.first_name = "Jake"; u.last_name = "Russo"; u.password = "password123"
end
vhs_parent_1 = User.find_or_create_by!(email: "sarah.webb@example.com") do |u|
  u.first_name = "Sarah"; u.last_name = "Webb"; u.password = "password123"
end
vhs_parent_2 = User.find_or_create_by!(email: "ali.hassan@example.com") do |u|
  u.first_name = "Ali"; u.last_name = "Hassan"; u.password = "password123"
end

[ vhs_student_1, vhs_student_2, vhs_student_3 ].each do |s|
  SeasonMembership.find_or_create_by!(user: s, season: vhs_swim_season) { |sm| sm.role = :student }
end
[ vhs_parent_1, vhs_parent_2 ].each do |p|
  SeasonMembership.find_or_create_by!(user: p, season: vhs_swim_season) { |sm| sm.role = :parent }
end

ParentStudentRelationship.find_or_create_by!(parent: vhs_parent_1, student: vhs_student_1)
ParentStudentRelationship.find_or_create_by!(parent: vhs_parent_2, student: vhs_student_2)

vhs_general = Channel.find_or_create_by!(season: vhs_swim_season, name: "general") do |c|
  c.created_by = vhs_head_coach; c.channel_type = :conversation; c.system_generated = true; c.active = true
end
vhs_announcements = Channel.find_or_create_by!(season: vhs_swim_season, name: "announcements") do |c|
  c.created_by = vhs_head_coach; c.channel_type = :broadcast; c.system_generated = true; c.active = true
end

[
  vhs_head_coach, vhs_ad,
  vhs_student_1, vhs_student_2, vhs_student_3, vhs_parent_1, vhs_parent_2,
].each do |u|
  ChannelMembership.find_or_create_by!(channel: vhs_general,       user: u)
  ChannelMembership.find_or_create_by!(channel: vhs_announcements, user: u)
end

Message.find_or_create_by!(channel: vhs_announcements, sender: vhs_head_coach,
  content: "Boys — welcome to the 2025-26 season! Big things ahead this year.") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: vhs_general, sender: vhs_student_1,
  content: "Can't wait! Time to drop some time this season.") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: vhs_general, sender: vhs_student_2,
  content: "Do we have a meet schedule yet?") { |m| m.flag_action = nil }
Message.find_or_create_by!(channel: vhs_general, sender: vhs_head_coach,
  content: "Schedule goes out Friday. Expect 8 dual meets + districts.") { |m| m.flag_action = nil }


# ── Default Mobile Theme ──────────────────────────────────────────────────────
# Match each user's mobile default to their primary school's dark theme,
# mirroring the dark-mode default they see on desktop.
# Only sets users with no theme yet — never overwrites a user's chosen theme.

school_dark_themes = {
  ahs.id => Theme.find_by!(name: "Hawks Dark"),
  bhs.id => Theme.find_by!(name: "Knights Dark"),
  chs.id => Theme.find_by!(name: "Eagles Dark")
}
mobile_default = Theme.find_by!(name: "Default Dark")

User.where(theme_id: nil).find_each do |u|
  school_id = InstitutionRole.where(user: u).where.not(school_id: nil).pick(:school_id)
  school_id ||= SeasonMembership
                  .joins(season: { sport: :school })
                  .where(user: u)
                  .pick("schools.id")
  u.update_columns(theme_id: (school_dark_themes[school_id] || mobile_default).id)
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
