class Api::V1::Plans::ManifestController < ApiController

  before_action :load_plan

  def add
    return permission_denied_error unless current_user && current_user.owns?(@plan)
    return error(500, "Insufficient params") unless params[:object_id] && params[:object_class] && params[:location]

    new_manifest = @plan.add_to_manifest(object: object, location: params[:location].to_i)
    render json: new_manifest
  end

  def remove
    return permission_denied_error unless current_user && current_user.owns?(@plan)
    return error(500, "Insufficient params") unless params[:object_id] && params[:object_class]

    new_manifest = @plan.remove_from_manifest(object: object, location: params[:location].to_i)
    render json: new_manifest
  end

  def move
    return permission_denied_error unless current_user && current_user.owns?(@plan)
    return error(500, "Insufficient params") unless params[:from] && params[:to]

    new_manifest = @plan.move_in_manifest(from: params[:from].to_i, to: params[:to].to_i)
    render json: new_manifest
  end

  private

  def load_plan
    @plan = Plan.find params[:id]
  end

  def object
    params[:object_class].constantize.find(params[:object_id])
  end

end