class Api::V1::Users::LocationsController < ApiController

  before_action :load_user, except: []

  def index
    render json: @user.locations
  end

  private

  def load_user
    @user = User.friendly.find params[:user_id]
  end

end