mod = angular.module('Models')
mod.factory 'PlanitMarker', ($timeout) ->

  class PlanitMarker

    @primaryPin: (place, show_popup = false) ->
      primaryMarker = L.marker(new L.LatLng(place.lat, place.lon), options={
        title: place.names[0],
        alt: place.names[0],
        placeObject: place,
        riseOnHover: true,
        properties: {
          placeObject: place,
        },
        icon: L.divIcon({
          className: 'default-map-div-icon',
          html: """ <div class='default-map-icon-tab p#{place.id}' id='p#{place.id}'><i class='#{place.meta_icon || ''}'></i><div class='arrow' /></div> """,
          iconSize: null,
        }),
      })
      if show_popup
        primaryMarker.bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,8)})
      else
        primaryMarker

    @contextPin: (place) ->
      L.marker([place.lat, place.lon], {
        icon: L.divIcon({
          className: 'contextual-map-div-icon',
          html: """ <div class='contextual-map-icon-tab p#{place.id}' id='p#{place.id}'><i class='#{place.meta_icon}'></i></div> """,
          iconSize: null,
        })
      }).bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,3), className: 'mini-popup'})

    @clusterPin: (cluster) ->
      children = cluster.getAllChildMarkers().length
      if children > 99
        L.divIcon
          className: "cluster-map-div-container"
          html: """ <span class='cluster-map-icon-tab large c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """
          iconSize: new L.Point(40,40)
      else if children > 9
        L.divIcon
          className: "cluster-map-div-container"
          html: """ <span class='cluster-map-icon-tab medium c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """
          iconSize: new L.Point(36,36)
      else
        L.divIcon
          className: "cluster-map-div-container"
          html: """ <span class='cluster-map-icon-tab small c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """
          iconSize: new L.Point(34,34)

  return PlanitMarker