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

  def in_cluster
    permission_denied_error unless current_user
    permission_denied_error unless cluster_id = params[:cluster_id]
    
    @cluster = Cluster.find_by( id: cluster_id )
    @places = Place.where( id: ObjectLocation.where( location_id: @cluster.locations.pluck(:id), obj_type: 'Place' ).pluck( :obj_id ) )
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