mod = angular.module('Controllers')
mod.controller 'ItinerariesCtrl.new', ($scope, Flash, $http, $q) ->
  $s = $scope

  $s.search = ->
    return unless $s.locale && $s.destination
    
    $s._fetchVenue().then( $s._fetchPhoto ).then( $s._parseToYaml )


  # PRIVATE INTERFACE


  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"


  $s._fetchVenue = ->
    path = "#{$s._baseFsPath}search?query=#{$s.destination}&near=#{$s.locale}&oauth_token=#{$s._fsAuth}"
    $http.get(path)
      .success (res) ->
        Flash.success("Success!")
        $s.venue = res.response.venues[0]
      .error (res) ->
        Flash.error("Response: #{JSON.stringify res}")
    
  $s._fetchPhoto = ->
    return false unless $s.venue

    $http.get("#{$s._baseFsPath}#{$s.venue.id}/photos?oauth_token=#{$s._fsAuth}")
      .success (res) -> 
        firstPhoto = res.response.photos.items[0]
        if !firstPhoto 
          Flash.error("No photos! Response: #{JSON.stringify res}")
        photoSize = '300x500' # arbitrary
        prefix = firstPhoto.prefix
        suffix = firstPhoto.suffix
        $s.photo = "#{prefix}#{photoSize}#{suffix}"
      .error (res) -> 
        Flash.error("Photo response: #{JSON.stringify res}")  

  $s._parseToYaml =  ->
    if !$s.venue || ! $s.photo
      Flash.error("Error! Venue #{JSON.stringify $s.venue}, Photo #{JSON.stringify $s.photo}")
      return false

    $s.output = [
      "          -"
      "  name: #{$s.venue.name}"
      "  address: #{$s.venue.location.address}, #{$s.venue.location.city}, #{$s.venue.location.state}"
      "  lat: #{$s.venue.location.lat}"
      "  lon: #{$s.venue.location.lng}"
      "  website: #{$s.venue.url}"
      "  tab_image: #{$s.photo}"
      "  source: Foursquare"
      "  source_url: http://foursquare.com/v/#{$s.venue.id}"
    ].join("\n          ")
