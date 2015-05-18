mod = angular.module("Services")
mod.service 'NoSidebarMapEventManager', (F, $timeout, MapEventManager) ->

  class NoSidebarMapEventManager extends MapEventManager

    mouseEvent: (type, id) =>
      return unless type && id
      if @s.mobile
        switch type
          when 'pinClick' then false ; false
          when 'pinDblClick' then false ; false
          when 'clusterClick' then false ; false
      else if @s.web
        switch type
          when 'pinClick' then false
          when 'pinMouseenter' then false
          when 'pinMouseenterScroll' then false
          when 'pinMouseleave' then false
          when 'clusterMouseenter' then false
          when 'clusterMouseenterScroll' then false
          when 'clusterMouseleave' then false

  return NoSidebarMapEventManager