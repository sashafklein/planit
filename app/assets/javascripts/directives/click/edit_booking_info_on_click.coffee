angular.module("Common").directive 'editBookingInfoOnClick', (Modal) ->
  
  return {
    restrict: 'A'
    scope:
      item: '='
    link: (s, e, a) ->
      
      s.modal = new Modal('edit-booking-info')
      
      e.bind "click", (event) -> s.modal.show({ item: s.item })  
  }