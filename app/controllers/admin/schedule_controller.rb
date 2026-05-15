module Admin
  class ScheduleController < ApplicationController
    def index
      from = params[:from].present? ? Time.zone.parse(params[:from]) : Time.current.beginning_of_month
      to   = params[:to].present?   ? Time.zone.parse(params[:to])   : Time.current.end_of_month

      sports = accessible_sports
      if params[:sport_template_ids].present?
        ids = Array(params[:sport_template_ids]).map(&:to_i)
        sports = sports.where(sport_template_id: ids)
      end

      events = CalendarEvent.where(sport: sports).in_range(from, to).includes(sport: :school)
      render json: events.map { |e| serialize(e) }
    end

    private

    def accessible_sports
      base = Sport.active.joins(:school)

      inst_role = current_user.institution_roles.find_by(
        role: %w[super_admin district_admin school_admin athletic_director]
      )

      if inst_role
        return base if inst_role.role == "super_admin"

        if inst_role.district_id.present?
          return base.joins(school: :district).where(schools: { district_id: inst_role.district_id })
        else
          return base.where(school_id: inst_role.school_id)
        end
      end

      commissionerships = current_user.sport_commissionerships.active.to_a
      return Sport.none if commissionerships.empty?

      placeholders = commissionerships.map { "(districts.id = ? AND sports.sport_template_id = ?)" }
      values       = commissionerships.flat_map { |c| [ c.district_id, c.sport_template_id ] }
      base.joins(school: :district).where(placeholders.join(" OR "), *values)
    end

    def serialize(event)
      {
        id:          event.id,
        sport_id:    event.sport_id,
        sport_name:  event.sport.name,
        school_name: event.sport.school.name,
        title:       event.title,
        event_type:  event.event_type,
        home_away:   event.home_away,
        location:    event.location,
        opponent:    event.opponent,
        starts_at:   event.starts_at,
        ends_at:     event.ends_at,
        notes:       event.notes,
        status:      event.status
      }
    end
  end
end
