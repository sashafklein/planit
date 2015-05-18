class Api::V1::UsersController < ApiController

  before_action :load_user, except: [:create]

  def show
    permission_denied_error unless current_user
    render json: @user, serializer: UserSerializer
  end

  def load_user
    @user = User.find(params[:id])    
  end

end