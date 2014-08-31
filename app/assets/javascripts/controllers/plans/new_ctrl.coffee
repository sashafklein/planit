mod = angular.module('Controllers')
mod.controller 'Plans.NewCtrl', ($scope, Flash, $http, $q) ->
  
  #### SETUP
  $s = $scope
  $s.output = ''
  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"
  $s.errors = ''

  #### PUBLIC INTERFACE

  $s.batchFetch = ->
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
        $s.output += $s._yamlify(venue, row, photo)
      )
    , $q.when()

  #### PRIVATE INTERFACE

  $s._getVenue = (destination, locale) ->
    $http.get("#{$s._baseFsPath}explore?query=#{destination}&near=#{locale}&oauth_token=#{$s._fsAuth}")

  $s._getPhoto = (venue) ->
    $http.get("#{$s._baseFsPath}#{venue.id}/photos?oauth_token=#{$s._fsAuth}")

  $s._photoUrl = (res) ->
    photo = res.response.photos.items[0]
    photoSize = '180x120' # arbitrary
    return '' unless photo
    "#{photo.prefix}#{photoSize}#{photo.suffix}"

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
      }

  $s._addToYaml = -> $s.output += $s._yamlify($s.venue)

  $s._yamlify = (venue, row, photo) ->
    if venue

      now = new Date
      [
        "\n          -"
        "      name: #{row.destination}"
        "      local_name: #{venue.name}"
        "      notes: "
        "      address: #{venue.location?.address}, #{venue.location?.city}, #{venue.location?.state}"
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
        "      time_of_day: "
        "      parent_day: #{row.day || ''}"
        "      parent_cluster: 1"
      ].join("\n      ").replace(/\, undefined/g, '').replace(/undefined/g, '').replace(/\: \&/g, '').replace(/\: \,/g, '')
