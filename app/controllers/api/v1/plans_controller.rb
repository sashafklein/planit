class Api::V1::PlansController < ApiController

  before_action :load_plan, except: [:create]

  def create
    return permission_denied_error unless current_user
    name = params[:plan_name] || "Guide #{current_user.plans.count + 1}"
    plan = Plan.create_new!( current_user, name, params[:place_ids] )
    render json: plan, serializer: PlanSerializer
  end

  def show
    return permission_denied_error unless @plan && current_user_is_active # current_user.owns?(@plan)
    render json: @plan, serializer: PlanSerializer
  end

  def update
    return permission_denied_error unless @plan && current_user.owns?(@plan)
    @plan.update_attributes!( params.require(:plan).permit(:name) )
    render json: @plan, serializer: PlanSerializer
  end

  def add_item_from_place_data
    return permission_denied_error unless current_user
    return error(500, "Can't add a place without any place data!") unless params[:place]

    add_item(plan_id: params[:id], data: params[:place].compact)
  end

  def items
    return permission_denied_error unless current_user && current_user.owns?(@plan)
    
    render json: @plan.items.includes( mark: {place: [:images]} ), each_serializer: ItemSerializer
  end

  def add_items
    return permission_denied_error unless @plan && current_user.owns?(@plan)
    marks = Mark.where( user_id: current_user.id, place_id: params[:place_ids] )
    marks.each do |mark|
      Item.where( plan_id: @plan.id, mark_id: mark.id ).first_or_create!
    end
    success
  end

  def add_places
    return permission_denied_error unless @plan && current_user.owns?(@plan)

    Place.where(id: params[:place_ids]).find_each do |place|
      mark = current_user.marks.where(place_id: place.id).first_or_create!
      mark.items.where(plan_id: @plan.id).first_or_create!
    end

    success
  end

  def destroy_items
    return permission_denied_error unless @plan && current_user.owns?(@plan)
    if params[:item_ids].present?
      @plan.items.where( id: params[:item_ids] ).destroy_all
    elsif params[:place_ids].present?
      marks = Mark.where( user_id: current_user.id, place_id: params[:place_ids] )
      Item.where( plan_id: @plan.id, mark_id: marks.pluck(:id) ).destroy_all
    end
    success
  end

  def destroy
    return permission_denied_error unless @plan && current_user.owns?(@plan)
    @plan.destroy
    success
  end

  def copy
    user_id = params[:user_id] || current_user.try(:id)
    return permission_denied_error unless current_user_is_active
    copy_plan(user_id, params[:copy_manifest])
  end

  def located_near
    return permission_denied_error unless current_user_is_active
    coordinate = params[:coordinate]
    lat = coordinate.split(",").first.to_f.round(1)
    lon = coordinate.split(",").last.to_f.round(1)
    plans = Plan.all.select{ |p| p.uniq_abbreviated_coords.include?([lat,lon]) }
    render json: plans, each_serializer: PlanSerializer
  end

  def add_nearby
    return permission_denied_error unless current_user_is_active
    return permission_denied_error unless @plan && @plan.user_id == current_user.id
    location = @plan.add_nearby( params[:nearby], current_user )
    render json: location
  end

  def remove_nearby
    return permission_denied_error unless current_user_is_active
    return permission_denied_error unless @plan && @plan.user_id == current_user.id
    location_id = params[:location][:location_id]
    if location_id && plan_locations = PlanLocation.where( plan_id: @plan.id, location_id: location_id )
      plan_locations.destroy_all
      render json: location_id
    else
      error
    end
  end

  private

  def add_item(plan_id:, data:)
    if Rails.env.test?
      plan = current_user.plans.find_by(id: plan_id)
      item = plan.add_item_from_place_data!(current_user, data)
      render json: item, serializer: ItemSerializer
    else
      PlanAddItemFromPlaceDataJob.perform_later(user_id: current_user.id, plan_id: plan_id, data: data)
      render json: data
    end
  end

  def copy_plan(user_id, copy_manifest)
    if Rails.env.test?
      user = User.find(user_id)
      new_plan = @plan.copy!(new_user: user, copy_manifest: copy_manifest)
      render json: { id: new_plan.id }
    else
      DelayPlanCopyJob.perform_later(plan_id: @plan.id, user_id: user_id, copy_manifest: copy_manifest)
      success
    end
  end

  def load_plan
    if plan_id = params[:id]
      @plan = Plan.find( plan_id )
    end
  end

end