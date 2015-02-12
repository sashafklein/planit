# mod = angular.module('Models')
# mod.factory 'BucketList', ->

#   class BucketList

#     @catIconFor: (metacategories) ->
#       L.Control.ListMarkers = L.Control.extend(
#         includes: L.Mixin.Events
#         options:
#           layer: false
#           maxItems: 20
#           collapsed: false
#           label: 'title'
#           itemIcon: L.Icon.Default.imagePath + '/marker-icon.png'
#           itemArrow: '&#10148;'
#           maxZoom: 9
#           position: 'bottomleft'
#         initialize: (options) ->
#           L.Util.setOptions this, options
#           @_container = null
#           @_list = null
#           @_layer = @options.layer or new (L.LayerGroup)
#           return
#         onAdd: (map) ->
#           @_map = map
#           container = @_container = L.DomUtil.create('div', 'list-markers')
#           @_list = L.DomUtil.create('ul', 'list-markers-ul', container)
#           @_initToggle()
#           map.on 'moveend', @_updateList, this
#           @_updateList()
#           container
#         onRemove: (map) ->
#           map.off 'moveend', @_updateList, this
#           @_container = null
#           @_list = null
#           return
#         _createItem: (layer) ->
#           li = L.DomUtil.create('li', 'list-markers-li')
#           a = L.DomUtil.create('a', '', li)
#           icon = if @options.itemIcon then '<img src="' + @options.itemIcon + '" />' else ''
#           that = this
#           a.href = '#'
#           L.DomEvent.disableClickPropagation(a).on(a, 'click', L.DomEvent.stop, this).on(a, 'click', ((e) ->
#             @_moveTo layer.getLatLng()
#             return
#           ), this).on(a, 'mouseover', ((e) ->
#             that.fire 'item-mouseover', layer: layer
#             return
#           ), this).on a, 'mouseout', ((e) ->
#             that.fire 'item-mouseout', layer: layer
#             return
#           ), this
#           #console.log('_createItem',layer.options);
#           if layer.options.hasOwnProperty(@options.label)
#             a.innerHTML = icon + '<span>' + layer.options[@options.label] + '</span> <b>' + @options.itemArrow + '</b>'
#             #TODO use related marker icon!
#             #TODO use template for item
#           else
#             console.log 'propertyName \'' + @options.label + '\' not found in marker'
#           li
#         _updateList: ->
#           that = this
#           n = 0
#           @_list.innerHTML = ''
#           @_layer.eachLayer (layer) ->
#             if layer instanceof L.Marker
#               if that._map.getBounds().contains(layer.getLatLng())
#                 if ++n < that.options.maxItems
#                   that._list.appendChild that._createItem(layer)
#             return
#           return
#         _initToggle: ->

#           ### inspired by L.Control.Layers ###

#           container = @_container
#           #Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
#           container.setAttribute 'aria-haspopup', true
#           if !L.Browser.touch
#             L.DomEvent.disableClickPropagation container
#             #.disableScrollPropagation(container);
#           else
#             L.DomEvent.on container, 'click', L.DomEvent.stopPropagation
#           if @options.collapsed
#             @_collapse()
#             if !L.Browser.android
#               L.DomEvent.on(container, 'mouseover', @_expand, this).on container, 'mouseout', @_collapse, this
#             link = @_button = L.DomUtil.create('a', 'list-markers-toggle', container)
#             link.href = '#'
#             link.title = 'List Markers'
#             if L.Browser.touch
#               L.DomEvent.on(link, 'click', L.DomEvent.stop).on link, 'click', @_expand, this
#             else
#               L.DomEvent.on link, 'focus', @_expand, this
#             @_map.on 'click', @_collapse, this
#             # TODO keyboard accessibility
#           return
#         _expand: ->
#           @_container.className = @_container.className.replace(' list-markers-collapsed', '')
#           return
#         _collapse: ->
#           L.DomUtil.addClass @_container, 'list-markers-collapsed'
#           return
#         _moveTo: (latlng) ->
#           if @options.maxZoom
#             @_map.setView latlng, Math.min(@_map.getZoom(), @options.maxZoom)
#           else
#             @_map.panTo latlng
#           return
#       )

#       L.control.listMarkers = (options) ->
#         new (L.Control.ListMarkers)(options)

#       L.Map.addInitHook ->
#         if @options.listMarkersControl
#           @listMarkersControl = L.control.listMarkers(@options.listMarkersControl)
#           @addControl @listMarkersControl
#         return
#       return

#   return BucketList