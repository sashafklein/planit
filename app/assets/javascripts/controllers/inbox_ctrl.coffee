angular.module("Controllers").controller 'InboxCtrl', ($scope, Mark, Modal, ErrorReporter, Place) ->
  s = $scope

  s.chooseModal = new Modal('choose-mark-place')

  s.init = (savesToReviewIds) -> 
    Mark.where(id: savesToReviewIds, serializer: 'InboxMarkSerializer', scoped: true)
      .success (response) ->
        s.savesToReview = Mark.generateFromJSON(response)
      .error (response) ->
        ErrorReporter.fullSilent(response, 'InboxCtrl init', { mark_ids: savesToReviewIds })

  s.openMark = (mark) ->
    if mark.place_options?.length
      s.chooseModal.show({ mark: mark, destroy: s.deleteMark, choose: s.chooseMark })
    else
      mark.getPlaceOptions()
        .success (response) -> 
          mark.place_options = Place.generateFromJSON( response )
          s.chooseModal.show({ mark: mark, destroy: s.deleteMark, choose: s.chooseMark })
        .error (response) -> ErrorReporter.fullSilent( response, 'InboxCtrl openMark', { mark_id: mark.id })

  s._findMark = (mark_id) -> _.find( s.savesToReview, (m) -> m.id == mark_id )
  
  s.deleteMark = (mark, callback) -> 
    mark.destroy()
      .success -> s._removeMark(mark); callback?()
      .error -> ErrorReporter.report({ mark_id: mark_id, context: 'Trying to delete a mark in choose-mark-place modal'})

  s.chooseMark = (mark, place_option_id, callback) ->
    mark.choose( place_option_id )
      .success (response) ->
        mark.place_options = []
        s._removeMark( mark )
        callback?()
      .error (response) -> 
        callback?()
        ErrorReporter.fullSilent( response, 'chooseMarkPlace modal confirm', { mark_id: s.mark.id } )

  s._removeMark = (mark) -> 
    location = s.savesToReview.indexOf _.find( s.savesToReview, (m) -> m.id == mark.id )
    s.savesToReview.splice(location, 1) unless location == -1

  # s.savesToReviewToReview = gon.marks_to_review
  # s.getMarks = (userId) ->
  #   Mark.where(user_id: userId)