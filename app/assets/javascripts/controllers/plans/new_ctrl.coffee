mod = angular.module('Controllers')
mod.controller 'Plans.NewCtrl', ($scope, Flash, $http, $q) ->
  
  #### SETUP
  $s = $scope
  $s.output = ''

  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"
  $s._fsNear = "near"
  $s._fsKey = "oauth_token"

  $s._goAuth = "AIzaSyAYSMNkP2bxn5Z0pEoL-kYvR2oYT5l821Q"
  $s._baseGoPath = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
  $s._goNear = "location"
  $s._goKey = "radius=500&key"

  $s.errors = ''

  #### PUBLIC INTERFACE

  $s.batchFetch = ->
    if $s.API == 'foursquare'
      $s._foursquareFetch()
    else if $s.API == 'google'
      alert('google')
    else if $s.API == 'none'
      $s._noneFetch
    else
      $s._foursquareFetch()

  #### PRIVATE INTERFACE

  $s._noneFetch = ->
    return unless $s.csv
    $s.output = ""
    $s._rows($s.csv).reduce (promise, row) ->
      promise.then(->
        $s.output += $._printEmpty(row)
      )
    , $q.when()

  $s._foursquareFetch = ->
    return unless $s.csv
    $s.output = ""
    $s._rows($s.csv).reduce (promise, row) ->
      venue = null
      promise.then(->
        $s._getVenue(row.destination, row.locale)
          .error (response) ->
            $s.errors += "#{JSON.stringify(row)}\n"
            $q.when("Venue not found.")
      ).then((response) ->
        item = response.data.response.groups[0].items[0]
        if !item
          $s.errors += "#{JSON.stringify(row)}\n"
          return $q.promise
        else
          venue = item.venue
          $s._getPhoto venue
      ).then((response) ->
        return $q.promise unless response
        photo = $s._photoUrl(response.data)
        $s.photo = photo
        $s.output += $s._yamlifyFoursquare(venue, row, photo)
      )
    , $q.when()

  $s._googleFetch = ->
    return unless $s.csv
    $s.output = ""
    $s._rows($s.csv).reduce (promise, row) ->
      venue = null
      promise.then(->
        $s._getVenue(row.destination, row.locale)
          .error (response) ->
            $s.errors += "#{JSON.stringify(row)}\n"
            $q.when("Venue not found.")
      ).then((response) ->
        item = response.data.response.groups[0].items[0]
        if !item
          $s.errors += "#{JSON.stringify(row)}\n"
          return $q.promise
        else
          venue = item.venue
          $s._getPhoto venue
      ).then((response) ->
        return $q.promise unless response
        photo = $s._photoUrl(response.data)
        $s.photo = photo
        $s.output += $s._yamlifyFoursquare(venue, row, photo)
      )
    , $q.when()

  $s._printEmpty = ->
    [
      "\n          -"
      "      name: #{row.destination}"
      "      notes: "
      "      address: #{row.locale}"
      "      has_tab: true"
      "      lodging: #{row.lodging || ''}"
      "      meal: #{row.meal || ''}"
      "      parent_day: #{row.day || ''}"
    ].join("\n      ")

  $s._getVenue = (destination, locale) ->
    $http.get("#{$s._baseFsPath}explore?query=#{destination}&#{$s._fsNear}=#{locale}&#{$s._fsKey}=#{$s._fsAuth}")

  $s._getPhoto = (venue) ->
    $http.get("#{$s._baseFsPath}#{venue.id}/photos?oauth_token=#{$s._fsAuth}")

  $s._photoUrl = (res) ->
    photo = res.response.photos.items[0]
    photoSize = '180x120' # arbitrary
    #     return '' unless photo
    "#{photo.prefix}#{photoSize}#{photo.suffix}" if photo || ''
    #  "#{photo.prefix}#{photoSize}#{photo.suffix}"

  $s._rows = (csv) ->
    csvRows = csv.split("\n")

    _(csvRows).map (row) ->
      split = row.split(',')
      {
        destination: split[0]
        locale: split[1] || ''
        day: split[2] || ''
        lodging: split[3] || ''
        travel: split[4] || ''
        meal: split[5] || ''
        notes: split[6] || ''
        time_of_day: split[7] || ''
      }

  $s._addToYaml = -> 
  # $s.output += $s._yamlifyFoursquare($s.venue)
    $s.output += $s._yamlifyFoursquare($s.venue) if $s.API == 'foursquare' || $s.API == ''
    $s.output += $s._printEmpty() if $s.API == 'none'

  $s._yamlifyFoursquare = (venue, row, photo) ->
    if venue
      # if row.day && row.day == row.day
# plus one
      now = new Date
      [
        "\n          -"
        "      name: #{row.destination}"
        "      local_name: #{venue.name}"
        "      notes: #{row.notes || ''}"
        "      phone: #{venue.contact?.phone}"
        "      street_address: #{venue.location?.address}"
        "      city: #{venue.location?.city}"
        "      state: #{venue.location?.state}"
        "      country: #{venue.location?.country}"
        "      cross_street: #{venue.location?.crossStreet}"
        "      category: #{venue.categories[0]?.name}"
        "      price_tier: #{venue.price?.tier?}"
        "      rating: #{venue.rating}"
        "      rating_signals: #{venue.ratingSignals}"
        "      date_of_API_pull: #{now}"
        "      lat: #{venue.location?.lat}"
        "      lon: #{venue.location?.lng}"
        "      website: #{venue.url}"
        "      tab_image: #{photo || ''}"
        "      source: Foursquare"
        "      source_url: http://foursquare.com/v/#{venue.id}"
        "      travel_type: #{row.travel || ''}"
        "      has_tab: true"
        "      lodging: #{row.lodging || ''}"
        "      meal: #{row.meal || ''}"
        "      time_of_day: #{row.time_of_day || ''}"
        "      parent_day: #{row.day || ''}"
      ].join("\n      ").replace(/\, undefined/g, '').replace(/undefined/g, '').replace(/\: \&/g, '').replace(/\: \,/g, '')

  $s._yamlifyGoogle = (venue, row, photo) ->
    if venue
      # if row.day && row.day == row.day
# plus one
      now = new Date
      [
        "\n          -"
        "      name: #{row.destination}"
        "      local_name: #{venue.name}"
        "      notes: #{row.notes || ''}"
        "      phone: #{venue.contact?.phone}"
        "      street_address: #{venue.location?.address}"
        "      city: #{venue.location?.city}"
        "      state: #{venue.location?.state}"
        "      country: #{venue.location?.country}"
        "      cross_street: #{venue.location?.crossStreet}"
        "      category: #{venue.categories[0]?.name}"
        "      price_tier: #{venue.price?.tier?}"
        "      rating: #{venue.rating}"
        "      rating_signals: #{venue.ratingSignals}"
        "      date_of_API_pull: #{now}"
        "      lat: #{venue.location?.lat}"
        "      lon: #{venue.location?.lng}"
        "      website: #{venue.url}"
        "      tab_image: #{photo || ''}"
        "      source: Foursquare"
        "      source_url: http://foursquare.com/v/#{venue.id}"
        "      travel_type: #{row.travel || ''}"
        "      has_tab: true"
        "      lodging: #{row.lodging || ''}"
        "      meal: #{row.meal || ''}"
        "      time_of_day: #{row.time_of_day || ''}"
        "      parent_day: #{row.day || ''}"
      ].join("\n      ").replace(/\, undefined/g, '').replace(/undefined/g, '').replace(/\: \&/g, '').replace(/\: \,/g, '')
