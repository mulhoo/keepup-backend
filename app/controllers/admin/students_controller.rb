module Admin
  class StudentsController < ApplicationController
    def destroy
      user = User.find(params[:id])
      authorize user, policy_class: Admin::StudentPolicy
      user.destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Student not found" }, status: :not_found
    end
  end
end
