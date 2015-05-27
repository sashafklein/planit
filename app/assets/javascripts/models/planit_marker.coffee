mod = angular.module('Models')
mod.factory 'PlanitMarker', ($timeout, MetaCategory) ->

  class PlanitMarker

    constructor: (scope) ->
      @scope = scope

    pinIcon: (place) ->
      if place.foursquare_icon
        """<i class="minimap foursquare-icon" style="background-image: url('#{place.foursquare_icon.replace("bg_64","32")}')"></i>"""
      else
        """<i class="#{place.meta_icon || ''}" ></i>"""

    pinColor: (meta_category) -> MetaCategory.colorClass( meta_category )

    primaryPin: (place, show_popup = false) ->
      id = "p#{place.id}"
      events = """ onclick="mapMouseEvent('pinClick', '#{id}')" onmouseenter="mapMouseEvent('pinMouseenterScroll', '#{id}')" onmouseleave="mapMouseEvent('pinMouseleave', '#{id}')" """
      pin = _( @_basicPin(place) ).extend(
        icon:
          type: 'div'
          className: 'default-map-div-icon'
          html: """ <div class="default-map-icon-tab #{id} #{@pinColor( place.meta_categories[0] )}" id="#{id}" #{events}>#{@pinIcon( place )}<div class="arrow" /></div> """ 
          iconSize: null
      ).value()
      # return pin unless show_popup
      # pin.bindPopup("<a href='/places/#{place.id}' target='_self'>#{ place.name() }</a>")

    contextPin: (place) ->
      _( @_basicPin(place) ).extend(
        icon: 
          type: 'div'
          className: 'contextual-map-div-icon'
          html: """ <div onclick="mapMouseEvent('pinClick', id)" ondblclick="mapMouseEvent('pinDblClick', id)" class='contextual-map-icon-tab p#{place.id}' id='p#{place.id}'><i class='#{place.meta_icon}'></i></div> """
          iconSize: [18,18]
          iconAnchor: [9,9]
      ).value()
      # .bindPopup("<a href='/places/#{place.id}' target='_self'>#{ place.name() }</a>", {offset: new L.Point(0,3), className: 'mini-popup'})

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

    userMapLocationPin: (location) -> 
      test = "https://irs3.4sqi.net/img/general/622x440/186753_bXWfu1hl2seDr5TizbL0X-3EuuNWkKLKoDnmJ_YgvwE.jpg"
      _( @_locationPin(location) ).extend(
        icon: 
          type: 'div'
          className: 'user-map-single-div-icon'
          html: """ <div><div class="location-name-wrapper"><div class="location-name"><span>#{location.name}</span></div></div><img src="#{test}"></div> """
          iconSize: [40,40]
          iconAnchor: [20,38]
      ).value()

    userMapClusterPin: (cluster) ->
      test = "https://irs3.4sqi.net/img/general/622x440/186753_bXWfu1hl2seDr5TizbL0X-3EuuNWkKLKoDnmJ_YgvwE.jpg"
      L.divIcon
        type: 'div'
        className: 'user-map-cluster-div-icon'
        html: """ <div><div class="location-name-wrapper"><div class="location-name"><span>#{cluster.getAllChildMarkers().length} locations</span></div></div><img src="#{test}"></div> """
        iconSize: [40,40]
        iconAnchor: [20,38]

    _basicPin: (place) ->
      _(place).extend(
        hasImg: place.image?
        name: place.name
        title: place.name
        alt: place.name
        riseOnHover: true
        layer: 'primary'
        lng: place.lon
      ).value()

    _locationPin: (location) ->
      _(location).extend(
        title: location.name
        alt: location.name
        riseOnHover: true
        layer: 'locations'
        lng: location.lon
      ).value()

  return PlanitMarker