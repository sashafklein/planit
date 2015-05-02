angular.module("Common").service "SPItem", (CurrentUser, Item, Mark, Note, QueryString, Flash, ErrorReporter) ->
  class SPItem

    constructor: (item) -> _.extend( @, item )
    _itemObj: -> new Item( _.pick( @, ['id'] ) )

    currentUserSave: -> @.mark.place.savers.push CurrentUser.id
    currentUserUnsave: -> @.mark.place.savers.splice( @.mark.place.savers.indexOf( CurrentUser.id ), 1 )
    currentUserSaved: -> _.includes( @.mark.place.savers , CurrentUser.id )

    currentUserLove: -> @.mark.place.lovers.push CurrentUser.id
    currentUserUnlove: -> @.mark.place.lovers.splice( @.mark.place.lovers.indexOf( CurrentUser.id ), 1 )
    currentUserLoves: -> _.includes( @.mark.place.lovers , CurrentUser.id )

    currentUserBeen: -> @.mark.place.visitors.push CurrentUser.id
    currentUserUnbeen: -> @.mark.place.visitors.splice( @.mark.place.visitors.indexOf( CurrentUser.id ), 1 )
    currentUserVisited: -> _.includes( @.mark.place.visitors , CurrentUser.id )

    fsOpen: (doIt) ->
      return unless doIt and @.mark?.place?.fs_href?.length
      window.open( @.mark.place.fs_href, '_blank' )
      return

    destroy: (callback) -> 
      self = @
      @_itemObj().destroy()
        .success (response) -> 
          QueryString.modify({ m: null })
          Mark.remove( self.mark.place.id )
            .success (response) -> 
              Flash.success("'#{self.mark.place.names[0]}' Deleted")
              callback?()
            .error (response) -> ErrorReporter.report({ place_id: self.mark.place.id, user_id: CurrentUser.id, context: "Inside SPPlan, deleting a mark" })

        .error (response) -> ErrorReporter.fullSilent( response, 'SinglePagePlans SPItem deleteItem', { item_id: self.id } )

    saveNote: ->
      self = @
      return unless @?.note && @?.note.length > 0
      return unless @?.noteChanged == true
      @.notesSearched = false
      Note.create({ note: { object_id: @.id, object_type: @.class, body: @.note } })
        .success (response) ->
          self.note = response.body
          self.noteChanged = false
          self.notesSearched = true
        .error (response) ->
          ErrorReporter.fullSilent( response, "SPItem save note", { object_id: self.id, object_type: self.class, text: note })
          self.note = null
          self.noteChanged = false
          self.notesSearched = true

  return SPItem