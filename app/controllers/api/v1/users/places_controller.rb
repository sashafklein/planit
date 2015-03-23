class Api::V1::Users::PlacesController < ApiController

  before_action :load_user, except: []

  def index
    permission_denied_error unless current_user

    if @user == current_user
      render json: {
        current_user_pins: [],
        user_pins: serialize_places( @user ),
      }
    else
      render json: {
        current_user_pins: serialize_places( current_user ),
        user_pins: serialize_places( @user, false )
      }
    end
  end

  private

  def load_user
    @user = User.friendly.find params[:user_id]
  end

  def serialize_places(user, open=true)
    base_search = user.marks.with_places
    places = open ? base_search.places.includes(:images) : base_search.published.places.published.includes(:images)
    ActiveModel::ArraySerializer.new(places, each_serializer: MapPlaceSerializer)
  end

end