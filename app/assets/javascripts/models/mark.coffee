mod = angular.module("Models")
mod.factory "Mark", (BaseModel, $http, Place) ->
  
  class Mark extends BaseModel

    constructor: (_properties) ->
      properties = _.clone(_properties)
      @place = @extractHasOneRelation(Place, properties, 'place')
      _.extend(this, properties)

    @class: "Mark"
    class: Mark.class

    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Mark, json)
    @basePath: '/api/v1/marks'
    
    choose: (place_option_id) -> $http.post( "#{ @objectPath() }/choose", { place_option_id: place_option_id } )
    
    @remove: ( place_id ) -> $http.post( "#{ @basePath }/remove", { place_id: place_id } )

    @love: ( place_id ) -> $http.post( "#{ @basePath }/love", { place_id: place_id } )

    @unlove: ( place_id ) -> $http.post( "#{ @basePath }/unlove", { place_id: place_id } )

    @been: ( place_id ) -> $http.post( "#{ @basePath }/been", { place_id: place_id } )

    @notbeen: ( place_id ) -> $http.post( "#{ @basePath }/notbeen", { place_id: place_id } )

  return Mark