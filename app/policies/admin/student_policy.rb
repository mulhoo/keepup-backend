module Admin
  class StudentPolicy < ApplicationPolicy
    # record is a User being permanently purged

    def destroy?
      role = managing_role
      return false unless role
      return false if record.institution_roles.exists?
      in_scope?(role)
    end

    private

    def managing_role
      user.institution_roles.find_by(role: %w[district_admin school_admin])
    end

    def in_scope?(role)
      student_school_ids = record.season_memberships
                                 .joins(season: :sport)
                                 .pluck("sports.school_id")
                                 .to_set

      if role.district_admin?
        district_school_ids = School.where(district_id: role.district_id).pluck(:id).to_set
        (student_school_ids & district_school_ids).any?
      else
        student_school_ids.include?(role.school_id)
      end
    end
  end
end
