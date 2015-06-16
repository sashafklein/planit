mod = angular.module("Models")
mod.factory "Location", (BaseModel, $http) ->
  
  class Location extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Location, json)
    @basePath: '/api/v1/locations'

    @countryClusters: ( geonameId ) -> $http.get( "#{@basePath}/country_clusters", { params: { country_id: geonameId } } )

    @findWithGeonameObject: ( geonameObj ) -> $http.post( "#{@basePath}/find_with_geoname_object", { data: geonameObj } )

    @findWithGeonameId: ( geonameId ) -> $http.get( "#{@basePath}/find_with_geoname_id", { params: { geoname_id: geonameId } } )

  return Location