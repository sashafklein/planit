angular.module('Modals').directive 'editBookingInfo', (Modal) ->
  return { 
    replace: true
    transclude: false
    scope: 
      item: '='
    templateUrl: 'modals/edit_booking_info.html'
    link: (s, e) ->

      s._data = -> _.pick( s.item, ['start_date', 'end_date', 'end_time', 'start_time', 'confirmation'] )

      s.saveBookingInfo = -> 
        s.item.update s._data(), ((response) -> new Modal().hide())
  }
