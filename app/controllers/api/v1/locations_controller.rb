class Api::V1::LocationsController < ApiController

  def country_clusters
    permission_denied_error unless current_user
    permission_denied_error unless country_id = params[:country_id]
    
    @clusters = Cluster.where( country_id: country_id ).order( 'rank DESC' )
    render json: @clusters, each_serializer: ClusterSerializer
  end

end