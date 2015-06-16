angular.module("Directives").directive 'clusterView', (ErrorReporter, $timeout, MetaCategory) ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_cluster_view.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.matchingMarksInCluster = ( category, categorizeBy ) -> #sorted alphabetically
        marks = s.m.marksInCluster()
        switch categorizeBy
          when 'type' then _.sortBy( _.filter( marks, (p) -> p.meta_categories?[0] == category ) , (p) -> return p.names[0] )
          when 'alphabetical' then _.sortBy( _.filter( marks, (p) -> p.names?[0]?[0] == category ) , (p) -> return p.names[0] )
          when 'locale' then _.sortBy( _.filter( marks, (p) -> p.locality == category ) , (p) -> return p.names[0] )
          else []

      s.allCategories = -> 
        # ["See", "Food", "Stay", "Drink", "Shop", "Do", "Area", "Other", "Relax", "Help", "Transit"]
        _.compact( _.uniq( _.map( s.m.marksInCluster(), (p) -> p.meta_categories?[0] ) ) )

      s.colorClass = ( meta_category ) -> MetaCategory.colorClass( meta_category )
      
      s.typeIcon = ( marks, meta_category ) -> 
        itemsWithIcon = _.filter( marks, (m) -> m.meta_categories?[0] == meta_category )
        if itemsWithIcon[0] then itemsWithIcon[0].meta_icon else ''

      s.noteChange = (place) ->
        return unless _.include( place.savers, s.m.currentUserId )
        place.noteChanged = true if place.note != place.noteOriginal
        s._saveNoteOnDelay( place )

      s._saveNoteOnDelay = (place) ->
         _.debounce( ( (place) -> 
          place.saveNote() if place.noteChanged # Not just updated post API exchange
        ), 1500)

      s.openPlace = (id) -> s.m.placeId = id

      s.breadCrumbedCluster = -> s.m.currentLocation()?.name if s.m.currentLocationId

      window.cv = s

  }
