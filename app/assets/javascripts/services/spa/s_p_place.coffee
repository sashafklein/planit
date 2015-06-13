angular.module("SPA").service "SPPlace", (CurrentUser, Place, Mark, Note, QueryString, Flash, ErrorReporter, ClassFromString) ->
  class SPPlace

    constructor: (place) -> _.extend( @, place ); @.noteChanged = false
    _itemObj: -> new Place( _.pick( @, ['id'] ) )

    currentUserSave: -> @.savers.push CurrentUser.id
    currentUserUnsave: -> @.savers.splice( @.savers.indexOf( CurrentUser.id ), 1 )
    currentUserSaved: -> _.includes( @.savers , CurrentUser.id )

    currentUserLove: -> @.lovers.push CurrentUser.id
    currentUserUnlove: -> @.lovers.splice( @.lovers.indexOf( CurrentUser.id ), 1 )
    currentUserLoves: -> _.includes( @.lovers , CurrentUser.id )

    currentUserBeen: -> @.visitors.push CurrentUser.id
    currentUserUnbeen: -> @.visitors.splice( @.visitors.indexOf( CurrentUser.id ), 1 )
    currentUserVisited: -> _.includes( @.visitors , CurrentUser.id )

    liClass: (index) -> ClassFromString.toClass( 'place li', @.name, index)
    fsOpen: (doIt) ->
      return unless doIt and @.fs_href?.length
      window.open( @.fs_href, '_blank' )
      return

    destroy: (callback) -> 
      self = @
      Mark.remove( @.id )
        .success (response) -> 
          callback?()
        .error (response) -> ErrorReporter.loud("SPPlace destroy", { place_id: self.id, user_id: CurrentUser.id })

    saveNote: ->
      self = @
      return unless self.noteChanged == true && !self.updatingNote
      self.updatingNote = true
      
      Note.create({ note: { obj_id: self.id, obj_type: 'Place', body: self.note } })
        .success (response) ->
          self.note = response.body
          self.noteChanged = false
          self.updatingNote = false
        .error (response) ->
          ErrorReporter.silent( response, "SPPlace save note", { place_id: self.id, user_id: CurrentUser.id, body: self.note })     
          self.note = null
          self.updatingNote = false

    # update: (data, callback) ->
    #   self = @
    #   self._itemObj().update( item: data )
    #     .success (response) ->
    #       _.forEach data, (k, v) -> self[k] = v
    #       callback?()
    #     .error (response) -> 
    #       ErrorReporter.silent(response, "SPPlace update", { id: self.id, data: data })

  return SPPlace