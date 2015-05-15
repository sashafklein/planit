class Api::V1::ItemsController < ApiController

  before_action :load_item, only: [:destroy, :update, :show]
  
  def show
    return permission_denied_error unless current_user

    render json: @item, serializer: ItemSerializer
  end

  def index
    return permission_denied_error unless current_user
    where = params[:conditions] ? JSON.parse(params[:conditions]) : {}
    return permission_denied_error if where && where[:plan_id] && !current_user.owns?( Plan.find(where[:plan_id]) )

    serializer = Array(params[:also_serialize]).flatten.compact.include?("hours") ? ItemSerializerWithHours : ItemSerializer
    render json: Item.with_places.includes(:mark).where( where ), each_serializer: serializer
  end

  def destroy
    return permission_denied_error unless current_user_is_active
    return permission_denied_error unless current_user.owns?(@item.plan)

    if @item.destroy
      render json: @item, serializer: ItemSerializer
    else
      error(message: "Failed to destroy item")
    end
  end

  def update
    @item.update_attributes!( item_params )
    success
  end

  private

  def load_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:start_time, :end_time, :start_date, :end_date, :confirmation)
  end
end