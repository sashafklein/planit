class Api::V1::ItemsController < ApiController
  
  before_action :load_user, only: :create
  
  before_action :cors_set_access_control_headers, only: [:create]
  after_action :cors_set_access_control_headers, only: [:create]

  def create
    return error(404, "User not found") unless @user
    
    completed_params = FourSquareCompleter.new(params[:item]).complete!
    if completed_params != params[:item]
      item = @user.items.from_flat_hash!(completed_params)
      render json: item, serializer: ItemSerializer
    else
      error(500, "We couldn't find enough information!")
    end
  end

  private

  def load_user
    @user = User.friendly.find(params[:user_id])
  rescue
    @user = nil
  end

  def item_params
    params.require(:item)
  end
end