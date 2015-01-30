class Api::V1::Plans::PlacesController < ApiController

  before_action :load_plan, except: []

  def index
    permission_denied_error unless current_user

    if @plan.user_id == current_user
      render( json: serialize_places( @plan ) )
      # render( json: serialize_places( @plan, true ) )
    else
      render( json: serialize_places( @plan ) )
    end
  end

  private

  def load_plan
    @plan = Plan.friendly.find params[:plan_id]
  end

  def serialize_places(user, published=false)
    places = published ? @plan.items.marks.published.places : @plan.items.marks.places
    ActiveModel::ArraySerializer.new(places, each_serializer: MapPlaceSerializer)
  end

end