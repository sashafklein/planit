class Api::V1::Users::TrustCircleController < ApiController

  before_action :load_user, except: []

  def index
    permission_denied_error unless current_user
    render json: User.all, each_serializer: JsUserSerializer
  end

  private

  def load_user
    @user = User.friendly.find params[:user_id]
  end

end