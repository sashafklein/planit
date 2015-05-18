angular.module("Controllers").controller 'InboxCtrl', ($scope, Mark, Modal, ErrorReporter) ->
  s = $scope

  s.chooseModal = new Modal('chooseMarkPlace')

  s.deleted = []

  s.marks = []

  s.openMark = (mark_id) -> 
    return if s._hasBeenDeleted(mark_id)

    return s.chooseModal.show({ mark: s._findMark( mark_id ) }) if s._findMark( mark_id )
    
    Mark.find( mark_id )
      .success (response) -> 
        s.marks.push Mark.generateFromJSON( response )
        s.chooseModal.show({ mark: response })
      .error (response) -> ErrorReporter.report({ mark_id: mark_id, context: 'Trying to find and then open a mark in Inbox'})

  s._findMark = (mark_id) -> _.find( s.marks, (m) -> m.id == mark_id )
  s.deleteMark = (mark_id) -> 
    s.deleted.push mark_id
    # ask confirmation?
    new Mark({ id: mark_id }).destroy()
      .success -> 
        console.log("deleted #{mark_id}")
      .error -> ErrorReporter.report({ mark_id: mark_id, context: 'Trying to delete a mark in chooseMarkPlace modal'})

  s._hasBeenDeleted = (mark_id) -> s.deleted.indexOf(mark_id) != -1 
  # s.marksToReview = gon.marks_to_review
  # s.getMarks = (userId) ->
  #   Mark.where(user_id: userId)