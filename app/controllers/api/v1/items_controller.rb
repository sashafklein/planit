class Api::V1::ItemsController < ApiController
  
  before_filter :load_user

  def create
    completed_params = FourSquareCompleter.new(params[:item]).complete
    @user.items.create(completed_params)
  end

  private

  def load_user
    @user = User.friendly.find(params[:user_id])
    error(404, "User not found") unless @user
  end

  def item_params
    params.require(:item)
  end
end