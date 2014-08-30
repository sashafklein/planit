angular.module('Common').factory 'MapOptions', () ->
  id: "nikoklein.j9bb9gab"
  access_token: "pk.eyJ1Ijoibmlrb2tsZWluIiwiYSI6IkprTE5iNkEifQ.IcUYpiiJ4NClaj1eAas4Mw"
  tiles: -> "http://api.tiles.mapbox.com/v4/#{@id}/{z}/{x}/{y}.png?access_token=#{@access_token}"
  attribution: (show) -> if show then 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>' else ''
  tileOptions: (attribute) -> { attribution: @attribution(attribute) , maxZoom: 18, minZoom: 2 }
  icon: (image) ->
    L.icon
      iconUrl:      image
      iconSize:     [19, 22]
      iconAnchor:   [8, 22]
      popupAnchor:  [1, -15]