angular.module("Models").factory "Note", (BaseModel, $http) ->
  
  class Note extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Note, json)
    @basePath: '/api/v1/notes'

    @findByObject: (object) -> $http.get( "#{@basePath}/find_by_object", params: { obj_type: object.class, obj_id: object.id } )
    @findAllNotesInPlan: (plan_id) -> $http.get( "#{@basePath}/find_all_notes_in_plan", params: { plan_id: plan_id } )

  return Note