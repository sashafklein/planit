class Api::V1::PlacesController < ApiController

  def show
    permission_denied_error unless current_user

    @place = Place.find(params[:id])
    render json: @place, serializer: PlaceSerializer
  end

  def index
    permission_denied_error unless current_user

    @places = params[:conditions] ? Place.where( JSON.parse(params[:conditions]) ) : Place.all
    render json: @places.includes( :images ), each_serializer: PlaceSerializer
  end

  def search
    permission_denied_error unless current_user
    render json: { } unless params[:q]

    places = Place.filtered_search({ 
      query: { query: params[:q], fields: ['names^10', 'categories', 'meta_categories'], fuzziness: 'AUTO' },
      filter: { query: params[:n], type: 'cross_fields', analyzer: 'standard', fields: ['sublocality', 'locality', 'region', 'country', 'postal_code'], fuzziness: 'AUTO' }
    }).records.limit(5)
    render json: places, each_serializer: SearchPlaceSerializer
  end

end