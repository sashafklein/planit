mod = angular.module('Models')
mod.factory 'PlanitMarker', ($timeout) ->

  class PlanitMarker

    constructor: (scope) ->
      @scope = scope

    primaryPin: (place, show_popup = false) ->
      _( @_basicPin(place) ).extend(
        icon:
          type: 'div'
          className: 'default-map-div-icon'
          html: """ <div class="default-map-icon-tab p#{place.id}" id="p#{place.id}" ><i class="#{place.meta_icon || ''}" ></i><div class="arrow" /></div> """
          iconSize: null
      ).value()
      # if show_popup
      #   primaryMarker.bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,8)})
      # else
      #   primaryMarker

    contextPin: (place) ->
      _( @_basicPin(place) ).extend(
        icon: 
          type: 'div'
          className: 'contextual-map-div-icon'
          html: """ <div class='contextual-map-icon-tab p#{place.id}' id='p#{place.id}'><i class='#{place.meta_icon}'></i></div> """
          iconSize: [18,18]
          iconAnchor: [9,9]
      ).value()
      # .bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,3), className: 'mini-popup'})

    clusterPin: (cluster) ->
      children = cluster.getAllChildMarkers().length
      if children > 99
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab large c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """,
          iconSize: new L.Point(40,40),
          iconAnchor: [20,20],
      else if children > 9
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab medium c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """,
          iconSize: new L.Point(36,36),
          iconAnchor: [18,18],
      else
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab small c#{cluster._leaflet_id}' id='c#{cluster._leaflet_id}'>#{children}</span> """,
          iconSize: new L.Point(34,34),
          iconAnchor: [17,17],

    _basicPin: (place) ->
      _(place).extend(
        title: place.names[0]
        alt: place.names[0]
        riseOnHover: true
        lng: place.lon
        layer: 'primary'
      ).value()

  return PlanitMarker