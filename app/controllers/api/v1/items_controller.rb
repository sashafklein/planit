class Api::V1::ItemsController < ApiController

  before_action :load_item, except: [:create]

  def create
    return permission_denied_error unless current_user
    name = params[:item_name] || "Guide #{current_user.items.count + 1}"
    item = item.create_new!( current_user, name, params[:place_ids] )
    render json: item, serializer: itemSerializer
  end

  def show
    return permission_denied_error unless @item && @item.user == current_user
    render json: @item, serializer: itemSerializer
  end

  def rename
    return permission_denied_error unless @item && @item.user == current_user
    @item.name = params[:item_name] || @item.name
    render json: @item, serializer: itemSerializer
  end

  def destroy
    return permission_denied_error unless @item && @item.user == current_user
    @item.destroy
    success
  end

  private

  def load_item
    if item_id = params[:id]
      @item = item.find( item_id )
    end
  end

end 