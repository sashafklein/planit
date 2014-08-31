mod = angular.module('Controllers')
mod.controller 'Plans.NewCtrl', ($scope, Flash, $http, $q) ->
  
  #### SETUP
  $s = $scope
  $s.output = ''
  $s._fsAuth = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  $s._baseFsPath = "https://api.foursquare.com/v2/venues/"


  #### PUBLIC INTERFACE

  $s.batchFetch = ->
    return unless $s.csv
    $s.output = ""
    $s.csv.split("\n").reduce ((promise, row) ->
      venue = null
      promise.then(->
        split = row.split(",")
        $s._getVenue split[0], split[1]
      ).then((response) ->
        venue = response.data.response.groups[0].items[0].venue
        $s._getPhoto venue
      ).then((response) ->
        photo = $s._photoUrl(response.data)
        $s.output += $s._yamlify(venue, row, photo)
      )
    ), $q.when()

  #### PRIVATE INTERFACE

  $s._addToOutput = (row) ->
    venue = null
    photo = ''
    $s._getVenue(row.destination, row.locale)
      .success (res) ->
        venue = res.response.groups[0].items[0].venue
      .then ->
        $s._getPhoto(venue).success (res) -> $s.photo = photo = $s._photoUrl(res)
      .then ->
        $s.output += $s._yamlify(venue, row, photo) 

  $s._getFullVenue = (destination, locale) ->

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
    unless venue
      Flash.error("YAML Parse Error! Venue! #{JSON.stringify venue}")
      return false

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
