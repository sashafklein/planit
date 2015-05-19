angular.module("Services").service "SPItem", (CurrentUser, Item, Mark, Note, QueryString, Flash, ErrorReporter, ClassFromString) ->
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

    liClass: (index) -> ClassFromString.toClass( 'item li', @mark.place.name, index)
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
      return unless @?.noteChanged == true
      @.noteSearched = false
      Note.create({ note: { obj_id: self.id, obj_type: 'Item', body: self.note } })
        .success (response) ->
          self.note = response.body
          self.noteChanged = false
          self.noteSearched = true
        .error (response) ->
          ErrorReporter.fullSilent( response, "SPItem save note", { obj_id: self.id, obj_type: self.class, body: self.note })
          self.note = null
          self.noteChanged = false
          self.noteSearched = true

    update: (data, callback) ->
      self = @
      self._itemObj().update( item: data )
        .success (response) ->
          _.forEach data, (k, v) -> self[k] = v
          callback?()
        .error (response) -> 
          ErrorReporter.fullSilent(response, "SPItem update", { id: self.id, data: data })

  return SPItem