# Hajos & KeepUp — Overview

## Hajos — The Ecosystem

**Hajos** is a comprehensive athletic management platform for competitive swimming, named after Alfred Hajós (first Olympic swimming champion). Built by a high school swim coach and software engineer to replace the fragmented tooling coaches deal with today (GroupMe, HyTek, FinalForms, spreadsheets).

**Four products:**

| Product | Purpose |
|---|---|
| **KeepUp** | Team communication and safety for high school athletics |
| **Streamline** | Universal portable swimmer profiles, persistent across teams/seasons |
| **Touchpad** | Meet management — replaces HyTek Meet Manager |
| **Delta** | AI-powered stroke analysis (name nods to the Netherlands / Dutch connection) |

**Strategy:** KeepUp ships first because every team has a communication problem right now. Winning a school district on KeepUp builds the trust and relationship to expand into the full Hajos suite. Long-term goal: one unified platform replacing the entire fragmented ecosystem.

**Brand:** Navy + cyan. Each product has a distinct icon — Streamline (triangular path mark), KeepUp (interlocking loops), Delta (fluid wave lines), Touchpad (circuit-board hands).

---

## KeepUp — The App

### What it is

A team communication and safety platform built specifically for **high school athletics** — designed to replace the dangerous pattern of coaches using consumer apps (GroupMe, etc.) with students. The founding incident: an unauthorized adult gained access to a coach's GroupMe and targeted a student-athlete.

### Stack

- **Rails 8** API-only (PostgreSQL)
- **JWT auth** (jti-based revocation)
- **solid_queue** for background jobs, **solid_cache** for caching
- **Pundit** for authorization
- **ActionCable** for WebSocket (real-time messaging)
- **Python FastAPI microservice** running Gemma 4 (GCP Cloud Run, separate container)
- **RSpec + FactoryBot** for testing

---

### Data Architecture

The schema has ~30 tables. The core hierarchy is:

```
District
  └── School
        └── Sport  (e.g. "Girls Varsity Swimming")
              └── Season  ← central scoping unit
                    ├── SeasonMembership (user + role: head_coach/assistant/student/parent)
                    ├── Channel → Messages
                    └── DmConversation → DirectMessages
```

**Key architectural decisions:**

- **Season is the scoping unit**, not Sport. Channels, DMs, and memberships all live under a Season, enabling year-over-year archiving with 7-year data retention.
- **InstitutionRole** handles district-level roles (district admin, athletic director) separately from sport-level roles.
- **SportTemplate** is the district-level sport definition; `Sport` is the school-level instantiation. Allows the district commissioner to manage sport types centrally.
- **CoopAuthorization** handles multi-school sports (co-ops).
- **SportCommissionership** tracks district-level sport commissioners.

**Safety/moderation tables:** `messages` and `direct_messages` both carry `flagged`, `moderation_score`, `flag_reason`. `MessageFlag`, `MessageChallenge`, `SafetyReviewSignal`, `ModerationNotification` form the full moderation pipeline. `AccessLog` tracks every privileged access with Gemma anomaly detection fields.

**Social/family tables:** `ParentStudentRelationship`, `ParentViewRequest` (parents requesting view access to student comms), `FamilyGroup`.

**Athletic data:** `CalendarEvent`, `TeamEventAnnotation`, `MeetResult`, `QualificationFlag`, `TimeStandard`, `CommissionerEvent`, `Venue`.

**Media/theming:** `SportEmoji` (custom team reactions with moderation queue), `Theme` (10 semantic color slots, mobile-only).

---

### AI Integration — Gemma 4 (6 roles)

The FastAPI microservice exposes six endpoints that Rails calls:

| Role | Endpoint | Who calls it | Notes |
|---|---|---|---|
| 1 | `/moderate` | Rails (coach/AD messages only) | Reference impl only for student content — students run Gemma on-device |
| 2 | `/analyze_access` | Rails async after each access log write | Metadata only, no message content |
| 3 | `/moderate_emoji` | Rails when emoji submitted | Multimodal — analyzes the image |
| 4 | `/translate` | Rails for coach/AD content | Student content translated on-device |
| 5 | `/summarize_meet` | Rails from structured score data | Generates human-readable meet summaries |
| 6 | `/generate_theme` | Rails from plain-language color description | AI-assisted school theme generation |

**Critical compliance boundary:** Student message content **never leaves the device** — Gemma 4 E4B runs on-device in the mobile app. Rails only receives the moderation result (score, flagged boolean, category), not the content for re-analysis. This is the COPPA/FERPA sales pitch to school districts.

---

### User Roles & Auth

- **District Admin** — manages schools, staff, season data for the district
- **Athletic Director (AD)** — manages sports/seasons at a school, approves emoji, reviews flags
- **Sport Commissioner** — district-level, manages cross-school events for a sport
- **Head Coach / Assistant Coach** — season-scoped, can post announcements, manage roster
- **Student** — season-scoped, can message in channels/DMs they're members of
- **Parent** — linked to students via `ParentStudentRelationship`, read access with approval flow

Auth is JWT with Microsoft OAuth support (school SSO) and invitation-token flow for new accounts.

---

### API Structure (routes)

Two namespaces:

**`/admin`** — district/school management (staff CRUD, sport commissioner assignment, season listing, member role updates, student removal)

**`/demo`** — the full app API used by the mobile client, gated behind `config.demo_mode`. Covers: sessions, messaging (channels + DMs), announcements, safety flows, family, results/meet data, time standards, themes, moderation, notifications, linked accounts, message challenges, parent view requests.

**`/uploads/presign`** — S3 presign flow. S3 keys are structured as `{district_subdomain}/{school_slug}/...`, auto-isolating districts in S3.

---

### Where things stand (as of May 2026)

The public demo-mode backend (`keepup-backend`, this repo) is the hackathon submission. It has:
- Full data model + schema
- Controllers for both namespaces
- Gemma 4 FastAPI microservice with all 6 roles
- S3 upload presign flow
- Demo seeds

The private backend (`keepup-backend-private`) contains the full product business logic that isn't being open-sourced. The hackathon submission is deliberately minimal to protect the full product vision (CC-BY 4.0 license requirement for winning submissions).
