angular.module("Common").directive 'listAndTripView', (User, ErrorReporter, Mark, Flash, Note, $timeout, MetaCategory) ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_list_and_trip_view.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.colorClass = ( meta_category ) -> MetaCategory.colorClass( meta_category )
      
      s.typeIcon = (items, meta_category) -> 
        itemsWithIcon = _.filter( items, (i) -> i.meta_category == meta_category )
        if itemsWithIcon[0] then itemsWithIcon[0].mark.place.meta_icon else ''

      s.noteChange = (item) ->
        item.noteChanged=true
        s._saveNoteOnDelay(item)

      s._saveNoteOnDelay = _.debounce( ( (item) -> item.saveNote() unless item.noteChanged == false ), 1500)

      s.closestLocation = (item) ->
        #   mostRecentItem = _.sortBy( s.m.plan().items, (i) -> i.updated_at ).reverse()[0]
        #   lat = mostRecentItem.mark?.place?.lat
        #   lon = mostRecentItem.mark?.place?.lon
        #   distance = 100000000000000
        #   nearby = null
        #   _.forEach( s.m.plan().locations, (location) -> 
        #     thisDistance = Distance.miles( [lat,lon], [location.lat,location.lon] )
        #     if thisDistance < distance then distance = thisDistance; nearby = location )
        #   $timeout(-> s.m.plan().setNearby( nearby ) )

  }
