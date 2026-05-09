# Seed data for local development — LWSD (Lake Washington School District) scenario.
# Run with: bin/rails db:seed
# Safe to re-run: all records use find_or_create_by! on natural keys.

puts "Seeding KeepUp development data..."

# ── District ──────────────────────────────────────────────────────────────────

lwsd = District.find_or_create_by!(name: "Lake Washington School District") do |d|
  d.city    = "Kirkland"
  d.state   = "WA"
  d.country = "US"
  d.active  = true
end

# ── Schools ───────────────────────────────────────────────────────────────────

lwhs = School.find_or_create_by!(name: "Lake Washington High School", district: lwsd) do |s|
  s.city   = "Kirkland"
  s.state  = "WA"
  s.active = true
end

ehs = School.find_or_create_by!(name: "Eastlake High School", district: lwsd) do |s|
  s.city   = "Sammamish"
  s.state  = "WA"
  s.active = true
end

jhs = School.find_or_create_by!(name: "Juanita High School", district: lwsd) do |s|
  s.city   = "Kirkland"
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

district_admin = User.find_or_create_by!(email: "admin@lwsd.org") do |u|
  u.first_name = "Sandra"
  u.last_name  = "Okafor"
  u.password   = "password123"
end

lw_ad = User.find_or_create_by!(email: "ad@lwhs.org") do |u|
  u.first_name = "Mike"
  u.last_name  = "Torres"
  u.password   = "password123"
end

ehs_ad = User.find_or_create_by!(email: "ad@ehs.org") do |u|
  u.first_name = "Rachel"
  u.last_name  = "Kim"
  u.password   = "password123"
end

head_coach = User.find_or_create_by!(email: "coach.swim@lwhs.org") do |u|
  u.first_name = "Chris"
  u.last_name  = "Nguyen"
  u.password   = "password123"
end

asst_coach = User.find_or_create_by!(email: "asst.swim@lwhs.org") do |u|
  u.first_name = "Dana"
  u.last_name  = "Patel"
  u.password   = "password123"
end

student_captain = User.find_or_create_by!(email: "captain@lwhs.student.org") do |u|
  u.first_name = "Alex"
  u.last_name  = "Rivera"
  u.password   = "password123"
end

student_1 = User.find_or_create_by!(email: "student1@lwhs.student.org") do |u|
  u.first_name = "Jordan"
  u.last_name  = "Lee"
  u.password   = "password123"
end

student_2 = User.find_or_create_by!(email: "student2@lwhs.student.org") do |u|
  u.first_name = "Taylor"
  u.last_name  = "Brooks"
  u.password   = "password123"
end

parent_1 = User.find_or_create_by!(email: "parent1@example.com") do |u|
  u.first_name = "Morgan"
  u.last_name  = "Lee"
  u.password   = "password123"
end

# ── Institution Roles ─────────────────────────────────────────────────────────

InstitutionRole.find_or_create_by!(user: district_admin, role: :district_admin, district: lwsd)
InstitutionRole.find_or_create_by!(user: lw_ad,  role: :athletic_director, school: lwhs)
InstitutionRole.find_or_create_by!(user: ehs_ad, role: :athletic_director, school: ehs)

# ── School Themes ─────────────────────────────────────────────────────────────
# ADs can set exactly one dark + one light theme for their school.
# LWHS example: navy + gold (Kangaroos school colors)

# LWHS Kangaroos — navy + gold school colors
Theme.find_or_create_by!(scope: :school, school: lwhs, variant: :dark) do |t|
  t.name                  = "Kangs Dark"
  t.created_by            = lw_ad
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

Theme.find_or_create_by!(scope: :school, school: lwhs, variant: :light) do |t|
  t.name                  = "Kangs Light"
  t.created_by            = lw_ad
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

# ── Sports ────────────────────────────────────────────────────────────────────

# LW Varsity Swimming — home school is LWHS, co-op with EHS
swimming = Sport.find_or_create_by!(name: "Varsity Swimming", school: lwhs) do |s|
  s.sport_type = "swimming"
  s.season     = "2025-26"
  s.status     = :pending
end

# Standard single-school sport at LWHS
water_polo = Sport.find_or_create_by!(name: "Water Polo", school: lwhs) do |s|
  s.sport_type = "water_polo"
  s.season     = "2025-26"
  s.status     = :active
end

# ── Co-op Authorizations (swimming is shared with EHS) ───────────────────────

lw_auth = CoopAuthorization.find_or_create_by!(sport: swimming, school: lwhs) do |ca|
  ca.athletic_director = lw_ad
  ca.status            = :approved
  ca.approved_at       = 1.week.ago
end

ehs_auth = CoopAuthorization.find_or_create_by!(sport: swimming, school: ehs) do |ca|
  ca.athletic_director = ehs_ad
  ca.status            = :approved
  ca.approved_at       = 1.week.ago
end

swimming.activate_if_ready!

# ── Sport Memberships ─────────────────────────────────────────────────────────

SportMembership.find_or_create_by!(user: head_coach,       sport: swimming, school: lwhs) { |sm| sm.role = :head_coach }
SportMembership.find_or_create_by!(user: asst_coach,       sport: swimming, school: lwhs) { |sm| sm.role = :assistant_coach }
SportMembership.find_or_create_by!(user: student_captain,  sport: swimming, school: lwhs) { |sm| sm.role = :student; sm.is_captain = true }
SportMembership.find_or_create_by!(user: student_1,        sport: swimming, school: lwhs) { |sm| sm.role = :student }
SportMembership.find_or_create_by!(user: student_2,        sport: swimming, school: ehs)  { |sm| sm.role = :student }
SportMembership.find_or_create_by!(user: parent_1,         sport: swimming, school: lwhs) { |sm| sm.role = :parent }

# ── Parent-Student Relationship ───────────────────────────────────────────────

ParentStudentRelationship.find_or_create_by!(parent: parent_1, student: student_1)

# ── Default Channels ──────────────────────────────────────────────────────────

general = Channel.find_or_create_by!(sport: swimming, name: "general") do |c|
  c.created_by      = head_coach
  c.channel_type    = :conversation
  c.system_generated = true
end

announcements = Channel.find_or_create_by!(sport: swimming, name: "announcements") do |c|
  c.created_by      = head_coach
  c.channel_type    = :broadcast
  c.system_generated = true
end

athletes_only = Channel.find_or_create_by!(sport: swimming, name: "athletes-only") do |c|
  c.created_by      = head_coach
  c.channel_type    = :athletes_only
  c.system_generated = true
end

# ── Channel Memberships ───────────────────────────────────────────────────────

[general, announcements].each do |channel|
  [head_coach, asst_coach, student_captain, student_1, student_2, parent_1].each do |user|
    ChannelMembership.find_or_create_by!(channel: channel, user: user)
  end
end

[athletes_only].each do |channel|
  [student_captain, student_1, student_2].each do |user|
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
  content: "Meet schedule for November is posted on the school athletics page. First away meet is Nov 14 @ Eastlake — bus departs at 3:30pm sharp.")

# ── General channel ───────────────────────────────────────────────────────────

msg_general_1 = Message.find_or_create_by!(channel: general, sender: student_captain,
  content: "Can't wait — see everyone Monday! Who's been training over the summer?")

msg_general_2 = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "Been doing open water swims at Juanita Beach. Feeling ready 🌊")

Message.find_or_create_by!(channel: general, sender: student_2,
  content: "Same! Anyone need a ride Monday? I have room for 2 more from the EHS side.")

Message.find_or_create_by!(channel: general, sender: asst_coach,
  content: "Love the energy. See you all at 6am — don't be late, we're starting dry-land immediately.")

Message.find_or_create_by!(channel: general, sender: student_captain,
  content: "Coach Nguyen, are we doing time trials first week or just base training?")

Message.find_or_create_by!(channel: general, sender: head_coach,
  content: "Time trials Thursday. Get some rest Tuesday and Wednesday.")

# ── Questionable message — held, ⚠️ visible to Jordan (student_1) ─────────────
# Gemma scored this 0.52 — borderline trash talk before a meet.
# Delivers to the channel but coach sees a review notification.

msg_questionable = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "Eastlake better watch out, I'm going to absolutely destroy their relays 😤") do |m|
  m.flagged          = true
  m.moderation_score = 0.52
  m.flag_reason      = "Potentially aggressive language targeting another school's athletes"
  m.flag_action      = "held"
end

# ── Severe message — blocked, 🚫 visible only to Jordan ──────────────────────
# Gemma scored this 0.88. Blocked entirely. Coach + AD notified.

msg_severe = Message.find_or_create_by!(channel: general, sender: student_1,
  content: "I swear if Coach benches me for the Eastlake meet I'm going to lose it on him") do |m|
  m.flagged          = true
  m.moderation_score = 0.88
  m.flag_reason      = "Implicit threat directed at a coach"
  m.flag_action      = "blocked"
end

# ── Athletes-only channel ─────────────────────────────────────────────────────

Message.find_or_create_by!(channel: athletes_only, sender: student_captain,
  content: "Team meeting after practice Wednesday — just athletes, captains have an agenda item to cover.")

Message.find_or_create_by!(channel: athletes_only, sender: student_2,
  content: "Are parents invited? Mine keeps asking about the banquet planning.")

Message.find_or_create_by!(channel: athletes_only, sender: student_captain,
  content: "No parents this one. Coaches set this channel up specifically so we have our own space.")

# ── Coaches-only channel ──────────────────────────────────────────────────────

coaches_only = Channel.find_or_create_by!(sport: swimming, name: "coaches") do |c|
  c.created_by       = head_coach
  c.channel_type     = :coaches_only
  c.system_generated = true
end

ChannelMembership.find_or_create_by!(channel: coaches_only, user: head_coach)
ChannelMembership.find_or_create_by!(channel: coaches_only, user: asst_coach)

Message.find_or_create_by!(channel: coaches_only, sender: head_coach,
  content: "Dana — I flagged Jordan's message in general for review. Can you keep an eye on that situation this week?")

Message.find_or_create_by!(channel: coaches_only, sender: asst_coach,
  content: "On it. I think there's some tension between Jordan and a few of the EHS kids. Will check in before Wednesday.")

# ── Reactions ─────────────────────────────────────────────────────────────────

Reaction.find_or_create_by!(message: msg_welcome,   user: student_captain, emoji: "🔥")
Reaction.find_or_create_by!(message: msg_welcome,   user: student_1,       emoji: "👍")
Reaction.find_or_create_by!(message: msg_general_1, user: student_1,       emoji: "👍")
Reaction.find_or_create_by!(message: msg_general_2, user: student_captain, emoji: "🌊")
Reaction.find_or_create_by!(message: msg_general_2, user: student_2,       emoji: "❤️")

# ── DM Conversations ──────────────────────────────────────────────────────────

# Coach ↔ Captain
dm_coach_captain = DmConversation.between(head_coach, student_captain, swimming)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: head_coach,
  content: "Hey Alex — great leadership at tryouts. I'm going to lean on you a lot this season.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: student_captain,
  content: "Thanks Coach. Quick question — should I be worried about Jordan? Seems a little on edge lately.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_captain, sender: head_coach,
  content: "I've noticed it too. Coach Patel and I are keeping an eye on it. Thanks for flagging.")

# Coach ↔ Student 1 (Jordan)
dm_coach_jordan = DmConversation.between(head_coach, student_1, swimming)
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: head_coach,
  content: "Jordan — checking in. How are you feeling about the season?")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: student_1,
  content: "Honestly kind of stressed. Trying to get my times down before Eastlake.")
DirectMessage.find_or_create_by!(dm_conversation: dm_coach_jordan, sender: head_coach,
  content: "That's normal. Let's talk after practice Wednesday — I have some thoughts on your pacing strategy.")

# Parent ↔ Coach
dm_parent_coach = DmConversation.between(parent_1, head_coach, swimming)
DirectMessage.find_or_create_by!(dm_conversation: dm_parent_coach, sender: parent_1,
  content: "Hi Coach Nguyen — Morgan here, Jordan's parent. Just wanted to introduce myself and say thank you for the welcome message.")
DirectMessage.find_or_create_by!(dm_conversation: dm_parent_coach, sender: head_coach,
  content: "Hi Morgan, great to meet you. Jordan has a lot of potential — excited to work with them this season.")

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
  recipient: lw_ad,
  message: msg_severe,
  notification_type: :severe_alert,
  recipient_role: :athletic_director
)

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
SportEmoji.find_or_create_by!(sport: swimming, name: ":kangaroo:") do |e|
  e.requested_by = student_captain
  e.image_url    = "https://placehold.co/128x128/1B2F5B/FFD700?text=🦘"
  e.status       = :approved
  e.reviewed_by  = head_coach
  e.reviewed_at  = 1.week.ago
end

puts "Done! Seeded LWSD scenario:"
puts "  District:  #{District.count}"
puts "  Schools:   #{School.count}"
puts "  Users:     #{User.count}"
puts "  Sports:    #{Sport.count}"
puts "  Channels:  #{Channel.count}"
puts "  Messages:  #{Message.count}"
puts "  Themes:    #{Theme.count} (#{Theme.system.count} system, #{Theme.school.count} school)"
