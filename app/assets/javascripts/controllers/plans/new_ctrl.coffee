mod = angular.module('Controllers')
mod.controller 'Plans.NewCtrl', ($scope, Flash, $http, $q) ->
  
  #### SETUP
  $s = $scope
  $s.output = ''

  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"

  $s._goAuth = "AIzaSyAYSMNkP2bxn5Z0pEoL-kYvR2oYT5l821Q"
  $s._baseGoPath = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
  $s._baseGoPhotoPath = "https://maps.googleapis.com/maps/api/place/photo?maxwidth="
  $s._baseGoDetailPath = "https://maps.googleapis.com/maps/api/place/details/json?placeid="

  $s.errors = ''

  #### PUBLIC INTERFACE

# ROUTE API

  $s.batchFetch = ->
    if $s.API == 'foursquare'
      $s._foursquareFetch()
    else if $s.API == 'google'
      $s._googleFetch()
    else if $s.API == 'none'
      $s._noneFetch()
    else if $s.API == 'KML'
      $s._noneFetch()
    else
      $s._foursquareFetch()

  #### PRIVATE INTERFACE

# PARSE INPUT

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

# OPENSTREETMAPS WORK

  $s._getOpenData = (destination, locale) ->
    $http.get("http://nominatim.openstreetmap.org/search?q=#{destination}%20#{locale}&format=json&addressdetails=1")

# FOURSQUARE WORK

  $s._foursquareFetch = ->
    return unless $s.csv
    $s.output = ""
    $s._rows($s.csv).reduce (promise, row) ->
      venue = null
      promise.then(->
        $s._getFsVenue(row.destination, row.locale)
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
          $s._getFsPhoto venue
      ).then((response) ->
        return $q.promise unless response
        tab_photo = $s._fsPhotoUrl(response.data, "180x120")
        full_photo = $s._fsPhotoUrl(response.data, "width1260")
        $s.photo = tab_photo
        $s.output += $s._yamlifyFoursquare(venue, row, tab_photo, full_photo)
      )
    , $q.when()

  $s._getFsVenue = (destination, locale) ->
    $http.get("#{$s._baseFsPath}explore?query=#{destination}&near=#{locale}&oauth_token=#{$s._fsAuth}")

  $s._getFsPhoto = (venue) ->
    $http.get("#{$s._baseFsPath}#{venue.id}/photos?oauth_token=#{$s._fsAuth}")

  $s._fsPhotoUrl = (res, photoSize) ->
    photo_item = res.response.photos.items[0]
    "#{photo_item.prefix}#{photoSize}#{photo_item.suffix}" if res || ''

  $s._yamlifyFoursquare = (venue, row, tab_photo, full_photo) ->
    if venue
      # if row.day && row.day == row.day plus one
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
        "      tab_image: #{tab_photo || ''}"
        "      full_image: #{full_photo || ''}"
        # "      image_credit: \x3Ca href='http://foursquare.com/v/#{venue.id}'>@#{venue. || 'Foursquare'}\x3C/a>"
        "      source: Foursquare"
        "      source_url: http://foursquare.com/v/#{venue.id}"
        "      travel_type: #{row.travel || ''}"
        "      has_tab: true"
        "      lodging: #{row.lodging || ''}"
        "      meal: #{row.meal || ''}"
        "      time_of_day: #{row.time_of_day || ''}"
        "      parent_day: #{row.day || ''}"
      ].join("\n      ").replace(/\, undefined/g, '').replace(/undefined/g, '').replace(/\: \&/g, '').replace(/\: \,/g, '')

# GOOGLE API WORK

#   $s._googleFetch = ->
#     return unless $s.csv
#     $s.output = ""
#     $s._rows($s.csv).reduce (promise, row) ->
#       venue = null
#       promise.then(->
#         $s._getGoVenue(row.destination, row.locale)
#           .error (response) ->
#             $s.errors += "#{JSON.stringify(row)}\n"
#             $q.when("Venue not found.")
#       ).then((response) ->
#         venue = response.data.results[0]
#         # break up formatted address -- split by comma [street address][city][state][country] 1320 Castro St, San Francisco, CA, United States
#         if !venue
#           $s.errors += "#{JSON.stringify(row)}\n"
#           return $q.promise
#         else
#           $s._getGoPhoto venue.photos.photo_reference
#       ).then((response) ->
#         $s._getGoDetails venue.place_id
#         # no return? how do I differentiate these results? want to call place_detail
#       ).then((response) ->
#         return $q.promise unless response
#         tab_photo = $s._goPhotoUrl(response.data, '180')
#         full_photo = $s._goPhotoUrl(response.data, '1260')
#         $s.photo = tab_photo
#         $s.output += $s._yamlifyGoogle(venue, row, tab_photo, full_photo)
#       )
#     , $q.when()

#   $s._getGoVenue = (destination, locale) ->
#     latlon_item = $s._getOpenData(destination, locale)
#       .success (response) ->
#         $http.get("#{$s._baseGoPath}query=#{destination}&location=#{response[0].lat},#{response[0].lon}&radius=500&key=#{$s._goAuth}")

#   $s._getGoPhoto = (res, photoSize) ->
#     $http.get("#{$s._baseGoPhotoPath}#{photoSize}&photoreference=#{res.photos[0].photo_reference}&key=#{$s._goAuth}")

#   $s._getGoDetails = (place_id) ->
#     $http.get("#{$s._baseGoDetailPath}#{place_id}&key=#{$s._goAuth}")

#   $s._goPhotoUrl = (res, photoSize) ->
#     photo = res.response.photos.items[0]
#     "#{photo.prefix}#{photoSize}#{photo.suffix}" if photo || ''

#   $s._yamlifyGoogle = (venue, row, photo) ->
#     if venue
#       # if row.day && row.day == row.day
# # plus one
#       now = new Date
#       [
#         "\n          -"
#         "      name: #{row.destination}"
#         "      local_name: #{venue.name}"
#         "      notes: #{row.notes || ''}"
#         "      local_phone: #{place_detail.formatted_phone_number}"
#         "      international_phone: #{place_detail.international_phone_number}"
#         "      street_address: #{place_detail.address_components[0][0]} #{place_detail.address_components[1][0]}"
#         "      city: #{place_detail.address_components[3][0]}"
#         "      state: #{place_detail.address_components[4][0]}"
#         "      postal_code: #{place_detail.address_components[5][0]}"
#         "      country: #{place_detail.address_components[6][0]}"
#         "      category: #{venue.types[0]?}"
#         "      category2: #{venue.types[1]?}"
#         "      category3: #{venue.types[2]?}"
#         "      price_tier: #{venue.price_level?}" # on a 5 point scale (0-4), 0 = free
#         "      rating: #{venue.rating*2}" # on a 5 point (1.0 to 5.0) vs. 10 point scale
#         "      date_of_API_pull: #{now}"
#         "      lat: #{venue.geometry.location?.lat}"
#         "      lon: #{venue.geometry.location?.lng}"
#         "      website: #{place_detail.website}"
#         "      tab_image: #{tab_photo || ''}"
#         "      full_image: #{full_photo || ''}"
#         # "      image_credit: \x3Ca href='http://foursquare.com/v/#{venue.id}'>@#{venue. || 'Foursquare'}\x3C/a>"
#         "      source: Google"
#         "      source_url: #{place_detail.url}"
#         "      travel_type: #{row.travel || ''}"
#         "      has_tab: true"
#         "      lodging: #{row.lodging || ''}"
#         "      meal: #{row.meal || ''}"
#         "      time_of_day: #{row.time_of_day || ''}"
#         "      parent_day: #{row.day || ''}"
#       ].join("\n      ").replace(/\, undefined/g, '').replace(/undefined/g, '').replace(/\: \&/g, '').replace(/\: \,/g, '')

# IF NO API

  $s._noneFetch = ->
    return unless $s.csv
    $s.output = ""
    venue = null
    $s._rows($s.csv).reduce (promise, row) ->
      promise.then(->
        $s._getOpenData(row.destination, row.locale)
          .error (response) ->
            $s.errors += "#{JSON.stringify(row)}\n"
            $q.when("Venue not found.")
      ).then((response) ->
        venue = response.data[0]
        $s.output += $s._printEmpty(venue, row) if venue
      )
    , $q.when()

  $s._printEmpty = (venue, row) ->
    
    [
      "\n          -"
      "      name: #{row.destination}"
      "      local_name: #{venue.address[0] || ''}"
      "      notes: "
      "      street_address: #{venue.address.road}"
      "      neighborhood: #{venue.neighborhood}"
      "      city: #{venue.address.city}"
      "      county: #{venue.address.county}"
      "      state: #{venue.address.state}"
      "      postal_code: #{venue.address.postcode}"
      "      country: #{venue.address.country}"
      "      lat: #{venue.lat}"
      "      lon: #{venue.lon}"
      "      category: #{venue.type}"
      "      category2: #{venue.class}"
      "      has_tab: true"
      "      source: OpenStreetMap"
      "      lodging: #{row.lodging || ''}"
      "      meal: #{row.meal || ''}"
      "      parent_day: #{row.day || ''}"
    ].join("\n      ")


  