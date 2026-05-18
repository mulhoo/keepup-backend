module Demo
  class TimeStandardsController < Demo::ApplicationController
    include DemoGuard
    # GET /demo/time_standards?sport_name=Girls+Swimming
    def index
      sport_name = params[:sport_name].to_s.downcase
      template = SportTemplate.all.find { |t| t.name.downcase.include?(sport_name.split.first || "") }
      standards = template ? TimeStandard.where(sport_template: template) : TimeStandard.none
      render json: standards.map { |s| serialize(s) }
    end

    # POST /demo/time_standards/bulk_update
    def bulk_update
      sport_name = params[:sport_name].to_s.downcase
      template = SportTemplate.all.find { |t| t.name.downcase.include?(sport_name.split.first || "") }
      return render json: { error: "Sport template not found" }, status: :unprocessable_entity unless template

      gender = params[:gender] || "girls"
      Array(params[:standards]).each do |s|
        TimeStandard.find_or_initialize_by(
          sport_template_id: template.id,
          gender:            gender,
          event_name:        s[:event]
        ).update!(
          kingco:             s[:kingco],
          districts_wildcard: s[:districts_wildcard],
          districts:          s[:districts],
          state:              s[:state]
        )
      end
      head :no_content
    end

    private

    def serialize(s)
      {
        event:              s.event_name,
        kingco:             s.kingco,
        districts_wildcard: s.districts_wildcard,
        districts:          s.districts,
        state:              s.state
      }
    end
  end
end
