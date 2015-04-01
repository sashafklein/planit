angular.module("Controllers").controller 'InboxCtrl', ($scope, Mark, Modal, ErrorReporter) ->
  s = $scope

  s.chooseModal = new Modal('chooseMarkPlace')
  # s.askModal = new Modal('askModal')
  s.deleted = []

  s.openMark = (mark_id) -> 
    unless s.deleted.indexOf(mark_id) != -1
      Mark.find( mark_id )
        .success (response) -> s.chooseModal.show({ mark: response })
        .error (response) -> ErrorReporter.report({ mark_id: mark_id, context: 'Trying to find and then open a mark in Inbox'})

  s.deleteMark = (mark_id) -> 
    s.deleted.push mark_id
    # ask confirmation?
    new Mark({ id: mark_id }).destroy()
      .success -> 
        console.log("deleted #{mark_id}")
      .error -> ErrorReporter.report({ mark_id: mark_id, context: 'Trying to delete a mark in chooseMarkPlace modal'})

  # s.marksToReview = gon.marks_to_review
  # s.getMarks = (userId) ->
  #   Mark.where(user_id: userId)