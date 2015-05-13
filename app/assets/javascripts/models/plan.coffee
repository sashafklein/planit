mod = angular.module("Models")
mod.factory "Plan", (BaseModel, $http) ->
  
  class Plan extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Plan, json)
    @basePath: '/api/v1/plans'

    @findPlaces: (id) -> $http.get( "#{@objectPath(id)}/places" )

    @KML: (id) -> $http.get( "#{@objectPath(id)}/kml" )

    addPlaces: (place_ids) -> $http.post( "#{ @objectPath() }/add_places", { place_ids: place_ids })

    destroyItems: (place_ids, item_ids) -> 
      params = if item_ids?.length then { item_ids: item_ids } else { place_ids: place_ids }
      $http.post( "#{@objectPath()}/destroy_items", params )

    addItemFromPlaceData: (data) -> $http.post( "#{@objectPath()}/add_item_from_place_data", {place: data} )
    copy: (userId) -> $http.post( "#{ @objectPath() }/copy", { user_id: userId } )

    addToManifest: (object, location) -> $http.post( "#{@objectPath()}/add", { obj_class: object.class, obj_id: object.id, location: location, obj_name: object.name } )

    removeFromManifest: (object, location) -> $http.post( "#{@objectPath()}/remove", { obj_class: object.class, obj_id: object.id, location: location, obj_name: object.name } )
        
    moveInManifest: (from, to) -> $http.post( "#{@objectPath()}/move", { from: from, to: to } )

    items: -> $http.get( "#{@objectPath()}/items" )

    addNearby: (data) -> $http.post( "#{@objectPath()}/add_nearby", { nearby: data } )
    removeNearby: (id) -> $http.post( "#{@objectPath()}/remove_nearby", { location: id } )

    @locatedNear: (coordinate) -> $http.get( "#{@basePath}/located_near", { params: { coordinate: coordinate } } )

  return Plan