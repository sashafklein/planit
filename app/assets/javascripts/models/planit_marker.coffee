mod = angular.module('Models')
mod.factory 'PlanitMarker', ($timeout) ->

  class PlanitMarker

    constructor: (scope) ->
      @scope = scope

    primaryPin: (place, show_popup = false) ->
      id = "p#{place.id}"
      _( @_basicPin(place) ).extend(
        icon:
          type: 'div'
          className: 'default-map-div-icon'
          html: """ <div onclick="mapMouseEvent('pinClick', id)" ondblclick="mapMouseEvent('pinDblClick', id)" onmouseenter="mapMouseEvent('pinMouseenterScroll', id)" onmouseleave="mapMouseEvent('pinMouseleave', id)" class="default-map-icon-tab #{id}" id="#{id}" ><i class="#{place.meta_icon || ''}" ></i><div class="arrow" /></div> """
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
          html: """ <div onclick="mapMouseEvent('pinClick', id)" ondblclick="mapMouseEvent('pinDblClick', id)" class='contextual-map-icon-tab p#{place.id}' id='p#{place.id}'><i class='#{place.meta_icon}'></i></div> """
          iconSize: [18,18]
          iconAnchor: [9,9]
      ).value()
      # .bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,3), className: 'mini-popup'})

    clusterPin: (cluster) ->
      children = cluster.getAllChildMarkers().length
      id = "c#{cluster._leaflet_id}"
      events = """ onclick="mapMouseEvent('clusterClick', id)" onmouseenter="mapMouseEvent('clusterMouseenterScroll', id)" onmouseleave="mapMouseEvent('clusterMouseleave', id)" """
      if children > 99
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab large #{id}' id='#{id}' #{events}>#{children}</span> """,
          iconSize: new L.Point(40,40),
          iconAnchor: [20,20],
      else if children > 9
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab medium #{id}' id='#{id}' #{events}>#{children}</span> """,
          iconSize: new L.Point(36,36),
          iconAnchor: [18,18],
      else
        L.divIcon
          className: "cluster-map-div-container",
          html: """ <span class='cluster-map-icon-tab small #{id}' id='#{id}' #{events}>#{children}</span> """,
          iconSize: new L.Point(34,34),
          iconAnchor: [17,17],

    _basicPin: (place) ->
      _(place).extend(
        hasImg: place.image?
        name: place.name
        title: place.name
        alt: place.name
        riseOnHover: true
        layer: 'primary'
      ).value()

  return PlanitMarker