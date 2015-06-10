angular.module("Directives").directive 'listView', (User, ErrorReporter, Mark, Flash, Note, $timeout, MetaCategory) ->
  return { 
    restrict: 'E'
    replace: true
    templateUrl: 'single/tabs/_list_view.html'
    scope:
      m: '='
    link: (s, e, a) ->

      s.colorClass = ( meta_category ) -> MetaCategory.colorClass( meta_category )
      
      s.typeIcon = (items, meta_category) -> 
        itemsWithIcon = _.filter( items, (i) -> i.meta_category == meta_category )
        if itemsWithIcon[0] then itemsWithIcon[0].mark.place.meta_icon else ''

      s.noteChange = (item) ->
        return unless item.mark? 
        s._saveNoteOnDelay(item)

      s._saveNoteOnDelay = _.debounce( ( (item) -> 
        item.mark.noteChanged = !item.mark.noteChanged
        item.saveNote() if item.mark.noteChanged # Not just updated post API exchange
      ), 1500)

      s.openPlace = (id) -> s.m.placeId = id

      window.lv = s

  }
