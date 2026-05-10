module NotificationChain
  # Returns the user who should be notified when `accessor` accesses data.
  # The chain:
  #   head_coach / assistant_coach -> athletic_director of accessor's school (in that sport)
  #   athletic_director            -> school_admin of accessor's school
  #   school_admin                 -> district_admin of accessor's district
  #   district_admin               -> dpa_contact of accessor's district
  #   dpa_contact                  -> nil (top of chain, no one above)
  def self.supervisor_for(accessor, season: nil)
    sm     = season && accessor.season_memberships.find_by(season:)
    role   = sm&.role
    school = season&.school

    case role
    when "head_coach", "assistant_coach"
      InstitutionRole.athletic_director.find_by(school:)&.user
    when "athletic_director"
      InstitutionRole.school_admin.find_by(school:)&.user
    else
      institution_supervisor_for(accessor)
    end
  end

  def self.institution_supervisor_for(accessor)
    ir = accessor.institution_roles.active.first
    return nil unless ir

    case ir.role
    when "school_admin"
      InstitutionRole.district_admin.find_by(district: ir.school&.district)&.user
    when "district_admin"
      InstitutionRole.dpa_contact.find_by(district: ir.district)&.user
    end
  end
end
