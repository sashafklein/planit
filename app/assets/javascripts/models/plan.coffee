mod = angular.module("Models")
mod.factory "Plan", (BaseModel, $http) ->
  
  class Plan extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Plan, json)
    @basePath: '/api/v1/plans'

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

    @KML: (id) -> $http.get( "#{@objectPath(id)}/kml" )

    addItems: (place_ids) -> $http.post( "#{@objectPath()}/add_items", { place_ids: place_ids } ) 
    destroyItems: (place_ids) -> $http.post( "#{@objectPath()}/destroy_items", { place_ids: place_ids } ) 
    addItemFromPlaceData: (data) -> $http.post( "#{@objectPath()}/add_item_from_place_data", {place: data} )
    copy: (userId) -> $http.post( "#{ @objectPath() }/copy", { user_id: userId } )

    addToManifest: (object, location) -> 
      return unless object?
      $http.post( "#{@objectPath()}/add", { obj_class: object.class, obj_id: object.id, location: location } )

    removeFromManifest: (object, location) -> 
      return unless object?
      $http.post( "#{@objectPath()}/remove", { obj_class: object.class, obj_id: object.id, location: location } )
        
    moveInManifest: (from, to) -> 
      return unless from? && to?
      $http.post( "#{@objectPath()}/move", { from: from, to: to } )

    items: -> $http.get( "#{@objectPath()}/items" )

    addNearby: (data) -> $http.post( "#{@objectPath()}/add_nearby", { nearby: data } )
    removeNearby: (location_id) -> $http.post( "#{@objectPath()}/remove_nearby", { location_id: location_id } )

    @locatedNear: (coordinate) -> $http.get( "#{@basePath}/located_near", { params: { coordinate: coordinate } } )

  return Plan