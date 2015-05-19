angular.module("Directives").directive 'tripView', (ErrorReporter, Item, Modal, SPItem) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_trip_view.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.initialized = false
      s.manifestItems = []

      s.addSection = (insertIndex) ->
        name = s.manifestItems[insertIndex].precedingSectionName
        delete s.manifestItems[insertIndex].precedingSectionName
        s._addToManifest({ class: 'Section', name: name}, insertIndex)

      s.focusOnSectionName = (itemIndex) ->
        $(".#{s.forClass(itemIndex)}").focus()
        return true

      s.forClass = (itemIndex) -> "for-#{itemIndex}"

      s.emptyHeight = -> 
        return {} if s.manifestItems?.length || !s.m.plan()?.items?.length
        { height: "#{ s.m.plan().items.length * 75 }px" }

      s._getManifestItems = ->
        return if !s.m.plan()? || s.manifestItems?.length
        s.m.plan().getManifestItems( (elements) -> s.manifestItems = elements )

      s._addToManifest = (item, insertIndex=0) -> 
        s.m.plan().addToManifest(item, insertIndex, s._reorderManifest)

      s._removeFromManifest = (itemIndex) ->
        item = s.manifestItems[itemIndex]
        s.m.plan().addToManifest(item, itemIndex, s._reorderManifest)

      s._moveInManifest = (from, to) ->
        s.m.plan().moveInManifest(from, to, s._reorderManifest)

      s._reorderManifest = (response) ->
        e.find('ul.manifest').find('li.list').remove()
        s._resetManifestItems(response)
        # s._setDragging(false)

      s._resetManifestItems = (response) ->
        s.m.plan().manifest = response
        newManifestItems = []
        _.forEach s.m.plan().manifest, (item, index) ->
          found = s._findItem(item)
          newManifestItems.push _.extend(found, { $$hashKey: "object:#{index}", index: index }) if found
        s.manifestItems = newManifestItems

      s._findItem = (manifestItem) -> 
        item =   _.find s.m.plan().items, (i) -> s._identical(i, manifestItem) 
        item ||= _.find s.manifestItems, (i) -> s._identical(i, manifestItem) 
        item ||= manifestItem

        return _.extend({}, item) unless item?.mark_id?
        item = new SPItem(item) unless item.constructor.name == 'SPItem'
        s._dup(item)

      s._identical = (i1, i2) -> (i1.class == i2.class) && (i1.id? && i1.id == i2.id) || (i1.name? && i1.name == i2.name)

      s._dup = (object) -> s._objectClasses[object.class].generateFromJSON( _.extend({}, object) )
      
      s._run = (func) -> setTimeout( func(), 0 )
      s._objectClasses = { Item: Item }
      
      s._initializeIt = -> 
        return unless s.m.mode == 'trip' && !s.initialized && s.m.plan()?
        s._getManifestItems()
        s._setDragging(true)
        s.initialized = true

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
              item = _.find s.m.plan().items, (i) -> i.id == parseInt( $(el).attr('href') )
              s._addToManifest(item, dropIndex)

        s.drakeM = dragula( [left], removeOnSpill: true)

        s.drakeM.on 'drop', (el, container, source) ->
          from = parseInt( $(el).attr("href") )
          to = $(el).parent().children().index(el)
          s._moveInManifest(from, to)
          
        s.drakeM.on 'remove', (el, container) ->
          index = parseInt( $(el).attr("href") )
          s._removeFromManifest(index)

      # INIT
      s.$watchGroup ['m.mode', 'm.plan()'], s._initializeIt, true

      window.trip = s
  }