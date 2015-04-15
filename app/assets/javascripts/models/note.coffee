angular.module("Models").factory "Note", (BaseModel, $http) ->
  
  class Note extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Note, json)
    @basePath: '/api/v1/notes'

    @findByObject: (object) -> $http.get( "#{@basePath}/find_by_object", params: { object_type: object.class, object_id: object.id } )

  return Note