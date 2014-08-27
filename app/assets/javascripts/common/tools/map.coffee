angular.module('Common').factory 'Map', () ->
  id: "nikoklein.j9bb9gab"
  access_token: "pk.eyJ1Ijoibmlrb2tsZWluIiwiYSI6IkprTE5iNkEifQ.IcUYpiiJ4NClaj1eAas4Mw"
  tiles: -> "http://api.tiles.mapbox.com/v4/#{@id}/{z}/{x}/{y}.png?access_token=#{@access_token}"
