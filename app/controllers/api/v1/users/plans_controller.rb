class Api::V1::Users::PlansController < ApiController

  before_action :load_user, except: []

  def index
    permission_denied_error unless current_user
    render json: @user.plans, each_serializer: PlanSerializer
  end

  private

  def load_user
    @user = User.friendly.find params[:user_id]
  end

end