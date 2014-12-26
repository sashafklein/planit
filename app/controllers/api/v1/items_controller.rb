class Api::V1::ItemsController < ApiController

  def index
    permission_denied_error unless current_user
    render json: current_user.items
  end
end