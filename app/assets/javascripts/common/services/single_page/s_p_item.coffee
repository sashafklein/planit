angular.module("Common").service "SPItem", (Note, ErrorReporter) ->
  class SPItem

    constructor: (item) -> @originalItem = item

    ownerLoves: ( ownerId ) -> _.includes( @originalItem.mark.place.lovers , ownerId )
    ownerVisited: ( ownerId ) -> _.includes( @originalItem.mark.place.visitors , ownerId )

    currentUserSave: ( currentUserId ) -> @originalItem.mark.place.savers.push currentUserId
    currentUserUnsave: ( currentUserId ) -> @originalItem.mark.place.savers.splice( @originalItem.mark.place.savers.indexOf( currentUserId ), 1 )
    currentUserSaved: ( currentUserId ) -> _.includes( @originalItem.mark.place.savers , currentUserId )

    currentUserLove: ( currentUserId ) -> @originalItem.mark.place.lovers.push currentUserId
    currentUserUnlove: ( currentUserId ) -> @originalItem.mark.place.lovers.splice( @originalItem.mark.place.lovers.indexOf( currentUserId ), 1 )
    currentUserLoves: ( currentUserId ) -> _.includes( @originalItem.mark.place.lovers , currentUserId )

    currentUserBeen: ( currentUserId ) -> @originalItem.mark.place.visitors.push currentUserId
    currentUserUnbeen: ( currentUserId ) -> @originalItem.mark.place.visitors.splice( @originalItem.mark.place.visitors.indexOf( currentUserId ), 1 )
    currentUserVisited: ( currentUserId ) -> _.includes( @originalItem.mark.place.visitors , currentUserId )

    fsOpen: (doIt) ->
      return unless doIt and @originalItem.placeHref()
      window.open( @originalItem.placeHref(), '_blank' )
      return

    saveNote: ->
      return unless @originalItem?.note && @originalItem?.note.length > 0
      return unless @originalItem?.noteChanged == true
      @originalItem.notesSearched = false
      Note.create({ note: { object_id: @originalItem.id, object_type: @originalItem.class, body: @originalItem.note } })
        .success (response) ->
          @originalItem.note = response.body
          @originalItem.noteChanged = false
          @originalItem.notesSearched = true
        .error (response) ->
          ErrorReporter.silentFull( response, "SPItem save note", { object_id: @originalItem.id, object_type: @originalItem.class, text: note })
          @originalItem.note = null
          @originalItem.noteChanged = false
          @originalItem.notesSearched = true

  return SPItem