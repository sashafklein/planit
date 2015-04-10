class Api::V1::ItemsController < ApiController


  def index
    return permission_denied_error unless current_user
    where = params[:conditions] ? JSON.parse(params[:conditions]) : {}
    return permission_denied_error if where && where[:plan_id] && !current_user.owns?( Plan.find(where[:plan_id]) )

    render json: Item.where( where ), each_serializer: ItemSerializer
  end
end