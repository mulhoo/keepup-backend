module Demo
  class ResultsController < DemoController
    before_action :require_coach_or_commissioner, only: [ :create ]
    before_action :require_commissioner, only: [ :approve ]

    # GET /demo/results — all results for commissioner or coach's sports
    def index
      results = MeetResult.includes(:home_school, :away_school, :uploaded_by)
        .order(date: :desc)
      render json: results.map { |r| serialize(r) }
    end

    # GET /demo/results/team?school_id=N
    def team
      school_id = params[:school_id].to_i
      results = MeetResult.where(home_school_id: school_id)
        .or(MeetResult.where(away_school_id: school_id))
        .includes(:home_school, :away_school, :uploaded_by)
        .order(date: :desc)
      render json: results.map { |r| serialize(r) }
    end

    # POST /demo/results
    def create
      result = MeetResult.new(
        sport_id:       params[:sport_id],
        home_school_id: params[:home_school_id],
        away_school_id:   params[:away_school_id].present? && params[:away_school_id].to_i > 0 ? params[:away_school_id].to_i : nil,
        away_school_name: params[:away_school],
        date:           params[:date],
        venue:          params[:venue],
        cross_division: params[:cross_division] || false,
        home_score:     params[:home_score].to_i,
        away_score:     params[:away_score].to_i,
        ai_summary:     params[:ai_summary],
        ai_focus:       params[:ai_focus],
        status:         "pending_opponent",
        uploaded_by:    current_user
      )
      highlights = Array(params[:highlights])
      result.ai_standouts = highlights
        .select { |h| h[:athlete].present? && h[:event].present? }
        .map { |h| "#{h[:athlete]} — #{h[:event]}: #{h[:time]}#{h[:pr] ? " · PR" : ""}" }
      result.events = []
      result.save!
      render json: serialize(result), status: :created
    end

    # PATCH /demo/results/:id/confirm — away team confirms score
    def confirm
      result = MeetResult.find(params[:id])
      result.update!(status: "pending_commissioner")
      render json: serialize(result)
    end

    # PATCH /demo/results/:id/approve — commissioner publishes and auto-generates qual flags
    def approve
      result = MeetResult.find(params[:id])
      result.update!(status: "published")
      generate_qual_flags(result)
      render json: serialize(result)
    end

    # POST /demo/results/generate_summary
    def generate_summary
      home_school = params[:home_school].to_s
      away_school = params[:away_school].to_s
      home_score  = params[:home_score].to_i
      away_score  = params[:away_score].to_i
      highlights  = Array(params[:highlights])

      home_wins  = home_score >= away_score
      winner     = home_wins ? home_school : away_school
      loser      = home_wins ? away_school : home_school
      win_score  = [ home_score, away_score ].max
      lose_score = [ home_score, away_score ].min
      margin     = win_score - lose_score

      hl_line = highlights
        .select { |h| h[:athlete].present? && h[:event].present? }
        .map { |h| "#{h[:athlete]} posted #{h[:time]} in the #{h[:event]}#{h[:pr] ? " (PR)" : ""}" }
        .join("; ")
      hl_line = " #{hl_line}." if hl_line.present?

      summary = if margin >= 30
        "#{winner} delivered a dominant #{home_wins ? "home" : "road"} performance, winning #{win_score}–#{lose_score} over #{loser}.#{hl_line} The team showed strength across relay events and outscored #{loser} in the majority of individual events. Solid preparation heading into the upcoming qualifier."
      elsif margin <= 14
        "A closely contested #{home_wins ? "home" : "road"} win for #{winner}, #{win_score}–#{lose_score} over #{loser}. Both teams produced competitive splits throughout, with the margin decided in the final relay events.#{hl_line} The return fixture should be closely contested."
      else
        "#{winner} took a #{home_wins ? "home" : "road"} win #{win_score}–#{lose_score} over #{loser}. The team showed consistent performance across individual events with relay times tracking above season average.#{hl_line} Good mid-season positioning heading into the qualifier."
      end

      render json: { summary: }
    end

    # POST /demo/results/parse_pdf — stub; production would run Claude on the PDF bytes
    def parse_pdf
      render json: {
        meet_name:    "Home Dual",
        date:         Date.today.to_s,
        venue:        "",
        home_school:  "",
        home_score:   0,
        away_school:  "",
        away_score:   0,
      }
    end

    private

    def require_coach_or_commissioner
      unless current_user_role.in?(%w[head_coach assistant_coach commissioner super_admin district_admin])
        render json: { error: "Forbidden" }, status: :forbidden
      end
    end

    def require_commissioner
      unless current_user_role.in?(%w[commissioner super_admin district_admin])
        render json: { error: "Forbidden" }, status: :forbidden
      end
    end

    def current_user_role
      current_user.institution_roles.first&.role.to_s
    end

    def serialize(r)
      {
        id:             r.id,
        date:           r.date.to_s,
        sport_name:     r.sport.name,
        home_school:    r.home_school.name,
        home_school_id: r.home_school_id,
        home_score:     r.home_score,
        away_school:    r.away_school&.name || r.away_school_name.to_s,
        away_school_id: r.away_school_id || 0,
        away_score:     r.away_score,
        venue:          r.venue,
        cross_division: r.cross_division,
        events:         r.events,
        ai_summary:     r.ai_summary,
        ai_standouts:   r.ai_standouts,
        ai_focus:       r.ai_focus,
        uploaded_by:    r.uploaded_by&.full_name,
        uploaded_at:    r.created_at&.iso8601,
        status:         r.status,
      }
    end

    def generate_qual_flags(result)
      standards = TimeStandard.where(sport_template: result.sport.sport_template)
      std_map = standards.index_by(&:event_name)

      result.events.each do |ev|
        std = std_map[ev["event"]]
        next unless std

        ev["results"].each do |r|
          time_str = r["time"]
          next if time_str.blank?

          %w[kingco districts_wildcard districts state].each do |level|
            cut = std.public_send(level)
            next if cut.blank?
            next unless time_beats_standard?(time_str, cut)

            result.qualification_flags.find_or_create_by!(
              athlete_name: r["athlete"],
              event_name:   ev["event"],
              level:        level
            ) do |f|
              f.school_abbr   = r["school"]
              f.time_str      = time_str
              f.standard_time = cut
              f.status        = "pending"
            end
          end
        end
      end
    end

    def time_beats_standard?(time_str, standard_str)
      parse_time(time_str) < parse_time(standard_str)
    rescue
      false
    end

    def parse_time(str)
      parts = str.to_s.split(":").map(&:to_f)
      parts.length == 2 ? parts[0] * 60 + parts[1] : parts[0]
    end
  end
end
