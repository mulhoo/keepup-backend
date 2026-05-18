module Demo
  class QualificationFlagsController < ApplicationController
    include DemoGuard
    # GET /demo/qualification_flags
    def index
      flags = QualificationFlag.joins(meet_result: :sport)
        .includes(:meet_result)
        .order(created_at: :desc)
      render json: flags.map { |f| serialize(f) }
    end

    # PATCH /demo/qualification_flags/:id/accept
    def accept
      flag = QualificationFlag.find(params[:id])
      flag.update!(status: "accepted")
      render json: serialize(flag)
    end

    private

    def serialize(f)
      {
        id:            f.id,
        result_id:     f.meet_result_id,
        athlete:       f.athlete_name,
        school:        f.school_abbr,
        event:         f.event_name,
        time:          f.time_str,
        level:         f.level,
        standard_time: f.standard_time,
        status:        f.status,
      }
    end
  end
end
