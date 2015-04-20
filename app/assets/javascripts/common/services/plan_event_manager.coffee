angular.module("Services").factory 'PlanEventManager', (F, $timeout, MapEventManager) ->

  class PlanEventManager extends MapEventManager

    mouseEvent: (type, id) =>
      @s.filtering = false
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

    redirect: (id) ->
      return unless id
      @_markerAndLiForPlaceId( id ).addClass('highlighted')
      place = _.find( s.places, (p) -> "p#{ p.id }" == id)
      window.open(place.fs_href, '_blank')
      return

  return PlanEventManager