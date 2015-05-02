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

      s._setDragging = (setRight=false) ->
        left = e.find('.items-in-manifest ul.plan-list-items')[0]

        if setRight
          right = e.find('.items-in-list ul.plan-list-items')[0]
          s.drakeLM = dragula [left, right], 
            revertOnSpill: true
            copy: true
            accepts: (el, target, source, sibling) ->
              return false if _.contains( source.classList, 'manifest' ) && _.contains( target.classList, 'list')
              true

          s.drakeLM.on 'drop', (el, container, source) ->
            if _.contains( container.classList, 'manifest' )
              dropIndex = _.map(container.children, (c) -> _.contains(c.classList, 'gu-transit') ).indexOf(true) || 0
              item = _.find s.m.items, (i) -> i.id == parseInt( $(el).attr('href') )
              s._addToManifest(item, dropIndex)

        s.drakeM = dragula( [left], removeOnSpill: true)
        s.drakeM.on 'drop', (el, container, source) ->
          from = parseInt( $(el).attr("href") )
          to = $(el).parent().children().index(el)
          s._moveInManifest(from, to)
        s.drakeM.on 'remove', (el, container) ->
          index = parseInt( $(el).attr("href") )
          s._removeFromManifest(index)


      s._addToManifest = (item, insertIndex=0) -> 
        s._runRequest( ( -> s.m.plan.addToManifest(item, insertIndex) ), 'addToManifest', { item_id: item.id })

      s._removeFromManifest = (itemIndex) ->
        item = s.manifestItems[itemIndex]
        s._runRequest( ( -> s.m.plan.removeFromManifest( item, itemIndex ) ), 'removeFromManifest', {item_id: item.id, remove_index: itemIndex} )

      s._moveInManifest = (from, to) ->
        s._runRequest( ( -> s.m.plan.moveInManifest(from, to) ), 'moveInManifest', { from: from, to: to } )

      s._runRequest = (request, name='', extraReporting={}) ->
        request()
          .success (response) ->
            e.find('ul.manifest').find('li.list').remove()
            s._resetManifestItems(response)
            s._setDragging(false)
          .error (response) ->
            ErrorReporter.defaultFull response, "singlePagePlans #{name}", _.extend({plan_id: s.m.plan.id}, extraReporting) 

      s._resetManifestItems = (response) ->
        s.m.list.manifest = response
        newManifestItems = []
        _.forEach s.m.plan.manifest, (item, index) ->
          if found = s._findItem(item)
            newManifestItems.push _.extend(found, { $$hashKey: "object:#{index}", index: index })
        s.manifestItems = newManifestItems

      s._findItem = (manifestItem) -> 
        item = _.find(s.m.items, (i) -> s._identical(i, manifestItem)) || _.find(s.manifestItems, (i) -> s._identical(i, manifestItem) || {})
        return null unless item?.class
        s._dup(item)

      s._identical = (i1, i2) -> i1.class == i2.class && i1.id == i2.id

      s._dup = (object) -> s._objectClasses[object.class].generateFromJSON( _.extend({}, object) )
      
      s._run = (func) -> setTimeout( func(), 0 )
      s._objectClasses = { Item: Item }
      
      # INIT
      s._getManifestItems()
      s._setDragging(true)
  }