mod = angular.module('Controllers')
mod.controller 'ItinerariesCtrl.new', ($scope, Flash, $http) ->
  $s = $scope

  $s.search = ->
    return unless $s.locale && $s.destination
    baseFsPath = "https://api.foursquare.com/v2/venues/search?query="
    fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    $http.get("#{baseFsPath}?query=#{$s.destination}&near=#{$s.locale}&oauth_token=#{fsAuth}")
      .success (res) ->
        Flash.success("Success!")
        console.log(res)
        $s.output = $s.parseToYaml(res)
        # $s.photos = $s.getPhoto(res)
        $s.outputfull = JSON.stringify(res)
      .error (res) ->
        Flash.error(response)

    $s.parseToYaml = (res) ->
      venue = res.response.venues[0]
      venueid = res.response.venues[0].id
      photo_url = $http.get("https://api.foursquare.com/v2/venues/#{venueid}/photos?oauth_token=#{fsAuth}")
        .success (response2) -> 
          $s.photofull = JSON.stringify(response2)
          console.log(response2)
        .error (response2) ->
          Flash.error("RESPONSE IS: #{JSON.stringify response}")  
      if !venue
        window.response = res
        return Flash.error("Venue is empty! Access full response by typing 'res' in console.")
      [
        "          -"
        "  name: #{venue.name}"
        "  address: #{venue.location.address}, #{venue.location.city}, #{venue.location.state}"
        "  lat: #{venue.location.lat}"
        "  lon: #{venue.location.lng}"
        "  website: #{venue.url}"
        # "  tab_image: #{photo_url.response[0].photos[0].prefix}180x120#{photo_url.response[0].photos[0].suffix}"
        "  source: Foursquare"
        "  source_url: http://foursquare.com/v/#{venue.id}"
        # ?ref=CLIENT_ID"  
      ].join("\n          ")
