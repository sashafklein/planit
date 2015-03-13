mod = angular.module('Controllers')
mod.controller 'Users.PlacesCtrl', ($scope, Place, User, PlanitMarker) ->
  $s = $scope

  # $s.getPlaces = (userId, currentUserId) ->
  #   $s._getPrimaryPlaces(userId).then ->
  #     if currentUserId != userId
  #       $s._getContextPlaces(currentUserId).then( -> $s._definePlaces() )
  #     else
  #       $s._definePlaces()

  # $s._definePlaces = ->
  #   $s.places = $s.allPlaces = $s.primaryPlaces.concat( if $s.contextPlaces then $s.contextPlaces else [] )

  # $s._getPrimaryPlaces = (userId) ->
  #   User.findPlaces( userId )
  #     .success (places) ->
  #       places = Place.generateFromJSON(places.user_pins)
  #       $s.primaryPlaces = _(places).map( (p) -> PlanitMarker.primaryPin(p) ).value()
  #     .error (response) ->
  #       console.log response

  # $s._getContextPlaces = (currentUserId) ->
  #   User.findPlaces( currentUserId )
  #     .success (places) ->
  #       places = Place.generateFromJSON( places.current_user_pins )
  #       $s.contextPlaces = _(places).map( (p) -> PlanitMarker.contextPin(p) ).value()
  #     .error (response) ->
  #       console.log response

  # $s.filtered = false

  # $s.filters = ->
  #   qString = window.document.location.search?.substr(1).split("&")
  #   pairs = _( _( qString ).select('length').value() ).map( (p) -> p.split('=') )
  #   _(pairs).reduce ( (result, a) -> result[ a[0] ] = a[1]; result ), {}

  # window.f = $s.filters()

  # $s.filterPlaces = -> 
  #   $s.places = if $s.filtered then PlaceFilterer.returnFiltered($s.places) else $s.allPlaces
  #   $s.filtered = !$s.filtered

  # window.s = $s

  # $s.findPrimaryPlaces = (userId) ->      
  #   User.findPlaces( userId )
  #     .success (places) -> 
  #       s.primaryPlaces = s.filterPlaces Place.generateFromJSON(places.user_pins)
  #     .error (response) ->
  #       console.log("Failed to grab places information!")
  #       console.log response

  # $s.findContextualPlaces = (userId) ->
  #   User.findPlaces( userId )
  #     .success (places) ->
  #       s.contextPlaces = Place.generateFromJSON(places.current_user_pins)
  #     .error (response) ->
  #       alert("Failed to grab current user's other places!")
  #       console.log response        