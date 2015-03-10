angular.module('Common').factory 'UserLocation', () ->

  class UserLocation

    @latLong = undefined
    
    @_getLocation: ->
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition( UserLocation._locationResult )      
  
    @_locationResult: (position) -> 
      UserLocation.latLong = position
  
    @showPositionInNewModal: (position) ->
      UserLocation._getLocation() unless position && (position.timestamp + 300000 > $.now())
      if position
        $('.new-pin-nearby#nearby').val [position.coords.latitude,position.coords.longitude].join(',')
        $('.new-pin-nearby#nearby').next().toggle Boolean($('.new-pin-nearby#nearby').val())

    # INITIALIZE

    @initializePage: () ->
      UserLocation._getLocation()
  
  return UserLocation
