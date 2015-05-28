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
        item.noteChanged=true
        s._saveNoteOnDelay(item)

      s._saveNoteOnDelay = _.debounce( ( (item) -> item.saveNote() unless item.noteChanged == false ), 1500)

  }
