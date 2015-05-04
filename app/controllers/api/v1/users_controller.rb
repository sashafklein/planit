class Api::V1::UsersController < ApiController

  def show
    permission_denied_error unless current_user
    
    @user = User.find(params[:id])
    render json: @user, serializer: UserSerializer
  end

end