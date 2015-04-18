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
    @plan = Plan.find params[:plan_id]
  end

  def serialize_places(user, published=false)
    places = published ? @plan.items.with_places.marks.published.places : @plan.items.with_places.marks.places
    ActiveModel::ArraySerializer.new(places, each_serializer: MapPlaceSerializer)
  end

end