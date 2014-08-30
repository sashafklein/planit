mod = angular.module('Controllers')
mod.controller 'Plans.NewCtrl', ($scope, Flash, $http, $q) ->
  $s = $scope

  $s.search = ->
    return unless $s.locale && $s.destination
    
    $s._fetchVenue().then( $s._fetchPhoto ).then( $s._parseToYaml )


  # PRIVATE INTERFACE


  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"


  $s._fetchVenue = ->
    # path = "#{$s._baseFsPath}search?query=#{$s.destination}&near=#{$s.locale}&oauth_token=#{$s._fsAuth}"
    path = "#{$s._baseFsPath}explore?query=#{$s.destination}&near=#{$s.locale}&oauth_token=#{$s._fsAuth}"
    $http.get(path)
      .success (res) ->
        Flash.success("Success!")
        # $s.venue = res.response.venues[0]
        $s.venue = res.response.groups[0].items[0].venue
        $s.outputfull = JSON.stringify res
      .error (res) ->
        Flash.error("Search Error! Response: #{JSON.stringify res}")
    
  $s._fetchPhoto = ->
    return false unless $s.venue

    $http.get("#{$s._baseFsPath}#{$s.venue.id}/photos?oauth_token=#{$s._fsAuth}")
      .success (res) -> 
        firstPhoto = res.response.photos.items[0]
        if !firstPhoto 
          Flash.error("Photo Error! No photos! Response: #{JSON.stringify res}")
        if firstPhoto == undefined
          Flash.error("Photo Error! No photos! Response: undefined")
          $s.photo = ""
        else
          photoSize = '180x120' # arbitrary
          prefix = firstPhoto.prefix
          suffix = firstPhoto.suffix
          $s.photo = "#{prefix}#{photoSize}#{suffix}"
      .error (res) -> 
        Flash.error("Photo Error! Photo #{JSON.stringify res}")  

  $s._parseToYaml =  ->
    if !$s.venue
      Flash.error("YAML Parse Error! Venue! #{JSON.stringify $s.venue}")
      return false
    
    now = new Date

    $s.output = [
      # "\n      -"
      # "  items:"
      # "    -"
      # "      name: #{$s.destination}"
      # "      local_name: #{$s.venue.name}"
      # "      notes: "
      # "      address: #{$s.venue.location.address}, #{$s.venue.location.city}, #{$s.venue.location.state}"

      "\n           phone: #{$s.venue.contact.phone}"
      "      street_address: #{$s.venue.location.address}"
      "      city: #{$s.venue.location.city}"
      "      state: #{$s.venue.location.state}"
      "      country: #{$s.venue.location.country}"
      "      cross_street: #{$s.venue.location.crossStreet}"
      "      category: #{$s.venue.categories[0].name}"
      "      price_tier: #{$s.venue.price?.tier?}"
      "      rating: #{$s.venue.rating}"
      "      rating_signals: #{$s.venue.ratingSignals}"
      "      date_of_API_pull: #{now}"

      # "      lat: #{$s.venue.location.lat}"
      # "      lon: #{$s.venue.location.lng}"
      # "      website: #{$s.venue.url}"
      # "      tab_image: #{$s.photo}"
      # "      source: Foursquare"
      # "      source_url: http://foursquare.com/v/#{$s.venue.id}"
      # "      travel_type: "
      # "      has_tab: true"
      # "      lodging: false"
      # "      time_of_day: "
      # "      parent_day: 1"
      # "      parent_cluster: 1"
    ].join("\n      ")
    # $s.output = [
    #   "\n      -"
    #   "  items:"
    #   "    -"
    #   "      name: #{$s.destination}"
    #   "      local_name: #{$s.venue.name}"
    #   "      notes: "
    #   "      address: #{$s.venue.location.address}, #{$s.venue.location.city}, #{$s.venue.location.state}"
    #   "      phone: #{$s.venue.contact.phone}"
    #   "      category: #{$s.venue.categories[0].name}"
    #   "      lat: #{$s.venue.location.lat}"
    #   "      lon: #{$s.venue.location.lng}"
    #   "      website: #{$s.venue.url}"
    #   "      tab_image: #{$s.photo}"
    #   "      source: Foursquare"
    #   "      source_url: http://foursquare.com/v/#{$s.venue.id}"
    #   "      travel_type: "
    #   "      has_tab: true"
    #   "      lodging: false"
    #   "      time_of_day: "
    #   "      parent_day: 1"
    #   "      parent_cluster: 1"
    # ].join("\n      ")
