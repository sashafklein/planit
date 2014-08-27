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
        $s.photos = $s.getPhoto(res)
        $s.outputfull = JSON.stringify(res)
      .error (res) ->
        Flash.error(response)

    # $s.getPhoto = (res) ->
    #   $http.get("https://api.foursquare.com/v2/venues/#{res.response.venues[0].id}/photos")
    #     .success (res) ->
    #       Flash.success("Success photos!")
    #       console.log(res)
    #     .error (res) ->
    #       Flash.error(response)

    $s.parseToYaml = (res) ->
      venue = res.response.venues[0]
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
        "  source: "
        "  source_url: "  
      ].join("\n          ")
