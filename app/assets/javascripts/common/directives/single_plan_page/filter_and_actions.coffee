angular.module("Common").directive 'filterAndActions', () ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'single/_filter_and_actions.html'
    scope:
      m: '='
    link: (s, e, a) ->
      
      s.toggleTopBar = (string) -> s.m.topBar = ( if s.m.topBar == string then null else string )
      s.selectAllText = -> if s.allSelected then 'Select None' else "Select All"
      
      s.toggleSelectAll = ->
        s.allSelected = !s.allSelected
        i.selected = s.allSelected for i in s.m.plan().items
      
      s.selectedItems = -> _.filter s.m.plan()?.items, (i) -> i.selected 

      s.removeSelected = -> s.m.plan().deleteItems( s.selectedItems() )
      s.removeSelectedText = ->
        count = s.selectedItems().length
        if count != 0 then "Remove #{count} From List" else "Remove From List"

      s.copySelected = ->   
      s.copySelectedText = ->
        count = s.selectedItems().length
        if count != 0 then "Copy #{count} To" else "Copy To"

      s.cancelOut = ->
        s.m.topBar = null
        i.selected = false for i in s.m.plan().items
        s.allSelected = false

      window.actions = s   
  }