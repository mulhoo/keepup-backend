module SeasonAccessible
  extend ActiveSupport::Concern

  private

  def accessible_seasons
    base = Season.active.includes(sport: :school)

    inst_role = current_user.institution_roles.find_by(
      role: InstitutionRole::MANAGEABLE_BY.keys + [ "super_admin" ]
    )

    if inst_role
      return base if inst_role.super_admin?

      if inst_role.district_id.present?
        return base.joins(sport: { school: :district })
                   .where(schools: { district_id: inst_role.district_id })
      else
        return base.joins(sport: :school)
                   .where(sports: { school_id: inst_role.school_id })
      end
    end

    commissionerships = current_user.sport_commissionerships.active.to_a
    if commissionerships.any?
      return accessible_seasons_for_commissioners(base, commissionerships)
    end

    coached_ids = current_user.season_memberships
                              .active
                              .where(role: :head_coach)
                              .pluck(:season_id)
    base.where(id: coached_ids)
  end

  def accessible_seasons_for_commissioners(base, commissionerships)
    placeholders = commissionerships.map { "(districts.id = ? AND sports.sport_template_id = ?)" }
    values       = commissionerships.flat_map { |c| [ c.district_id, c.sport_template_id ] }

    base.joins(sport: { school: :district })
        .where(placeholders.join(" OR "), *values)
  end
end
