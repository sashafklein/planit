angular.module("Common").directive 'addBookingInfoOnClick', (Modal) ->
  
  return {
    restrict: 'A'
    scope:
      item: '='
    link: (s, e, a) ->
      
      s.modal = new Modal('booking')
      
      e.bind "click", (event) -> s.modal.show({ item: s.item })  
  }