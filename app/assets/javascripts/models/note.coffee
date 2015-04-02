angular.module("Models").factory "Note", (BaseModel) ->
  
  class Note extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Note, json)
    @basePath: '/api/v1/notes'

  return Note
      