mod = angular.module("Services")
mod.service 'MapEventManager', (F, $timeout) ->

  class MapEventManager

    constructor: (scope) ->
      @s = scope

    selectCluster: (id, scroll) =>
      return unless id
      scroll = false unless @s.list
      @_markerAndLiForClusterId( @s.selectedClusterId = id ).addClass('highlighted')
      @_scrollToSidebarItem(id) if scroll == true && @s.web

    selectPlace: (id, scroll) =>
      return unless id
      scroll = false unless @s.list
      @_markerAndLiForPlaceId( @s.selectedPlaceId = id ).addClass('highlighted')
      @_scrollToSidebarItem(id) if scroll == true && @s.web

    deselectAll: => 
      @_markerAndLiForClusterId( @s.selectedClusterId ).removeClass('highlighted') if @s.selectedClusterId
      @_markerAndLiForPlaceId( @s.selectedPlaceId ).removeClass('highlighted') if @s.selectedPlaceId
      @s.selectedPlaceId = @s.selectedClusterId = null

    redirect: (id) => 
      return unless id
      document.location.href = "/places/#{id.slice(1)}"

    mouseEvent: (type, id) =>
      return unless type && id
      if @s.mobile
        switch type
          when 'pinClick' then @deselectAll() ; @selectPlace(id, false)
          when 'pinDblClick' then @redirect(id)
          when 'clusterClick' then @deselectAll() ; @selectCluster(id, false)
      else if @s.web
        switch type
          when 'pinClick' then @redirect(id)
          when 'pinMouseenter' then @selectPlace(id, false)
          when 'pinMouseenterScroll' then @selectPlace(id, true)
          when 'pinMouseleave' then @deselectAll(id)
          when 'clusterMouseenter' then @selectCluster(id, false)
          when 'clusterMouseenterScroll' then @selectCluster(id, true)
          when 'clusterMouseleave' then @deselectAll()

    _scrollToSidebarItem: (id) -> 
      $timeout ->
        $('#in-view-list').animate({
          scrollTop: $( "#" + id ).offset().top - $('#top-of-list').offset().top
        }, 0)

    _markerAndLiForPlaceId: (id) -> $(".default-map-icon-tab\##{id}, .place-li\##{id}")
    _markerAndLiForClusterId: (id) -> $(".cluster-map-icon-tab\##{id}, .cluster-li\##{id}")

    _ClusterDivs: -> [".cluster-map-icon-tab", ".cluster-li"]
    _MarkerDivs: -> [".place-li"]
    _EditDivs: -> [".edit-place", ".edit-places"]

  return MapEventManager