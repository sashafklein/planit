angular.module("Common").directive 'tripView', (ErrorReporter, Item) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_trip_view.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.manifestItems = []





      s._getManifestItems = ->
        return null unless ( item_ids = _.map(s.m.list.manifest, 'id') ).length

        Item.where( id: item_ids )
          .success (response) ->
            _.forEach s.m.list.manifest, (obj, index) ->
              s.manifestItems.push s._manifestWrap( _.find(response, (i) -> i.id == obj.id), index  )
          .error (response) ->
            ErrorReporter.fullSilent( response, 'tripView getManifestItems', { list_id: s.m.list.id, item_ids: item_ids } )

      s._manifestWrap = (item, index) ->
        _.extend( Item.generateFromJSON(item) , { index: index, pane: 'manifest' } )
      
      s._setDragging = ->
        left = e.find('.items-in-manifest ul.plan-list-items')[0]
        right = e.find('.items-in-list ul.plan-list-items')[0]
        s.drakeLM = dragula [left, right], 
          revertOnSpill: true
          copy: true
          accepts: (el, target, source, sibling) ->
            return false if _.contains( source.classList, 'manifest' ) && _.contains( target.classList, 'list')
            true

        s.drakeM = dragula( [left], removeOnSpill: true)

        s.drakeLM.on 'drop', (el, container, source) ->
          
        s.drakeM.on 'drop', (el, container, source) ->
      
          # debugger
      
      s._run = (func) ->
        setTimeout( func(), 0 )
          
      # INIT
      s._getManifestItems()
      s._setDragging()
  }