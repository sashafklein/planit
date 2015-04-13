class Api::V1::PlansController < ApiController

  before_action :load_plan, except: [:create]

  def create
    return permission_denied_error unless current_user
    name = params[:plan_name] || "Guide #{current_user.plans.count + 1}"
    plan = Plan.create_new!( current_user, name, params[:place_ids] )
    render json: plan, serializer: PlanSerializer
  end

  def show
    return permission_denied_error unless @plan && @plan.user == current_user
    render json: @plan, serializer: PlanSerializer
  end

  def update
    return permission_denied_error unless @plan && current_user.owns?(@plan)
    @plan.update_attributes!(params[:plan])
  end

  def rename
    return permission_denied_error unless @plan && @plan.user == current_user
    @plan.name = params[:plan_name] || @plan.name
    render json: @plan, serializer: PlanSerializer
  end

  def add_item_from_place_data
    return permission_denied_error unless current_user
    return error(500) unless params[:place]

    plan = current_user.plans.find(params[:id])

    item = plan.add_item_from_place_data! current_user, params[:place].compact
    return error(500, "Insufficient Place data.") unless item

    render json: item.mark.place, serializer: PlaceSerializer
  end

  def items
    return permission_denied_error unless current_user && current_user.owns?(@plan)
    
    render json: @plan.items.includes( mark: {place: [:images]} ), each_serializer: ItemSerializer
  end

  def add_items
    return permission_denied_error unless @plan && @plan.user == current_user
    marks = Mark.where( user_id: current_user.id, place_id: params[:place_ids] )
    marks.each do |mark|
      Item.where( plan_id: @plan.id, mark_id: mark.id ).first_or_create!
    end
    success
  end

  def destroy_items
    return permission_denied_error unless @plan && @plan.user == current_user
    marks = Mark.where( user_id: current_user.id, place_id: params[:place_ids] )
    Item.where( plan_id: @plan.id, mark_id: marks.pluck(:id) ).destroy_all
    success
  end

  def destroy
    return permission_denied_error unless @plan && @plan.user == current_user
    @plan.destroy
    success
  end

  private

  def load_plan
    if plan_id = params[:id]
      @plan = Plan.find( plan_id )
    end
  end

end