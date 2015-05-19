angular.module("Directives").directive 'filterAndActions', (Flash) ->
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
        return Flash.error("Please select items first") unless (count = s.selectedItems().length)
        return Flash.error("Please choose a plan to copy to") unless s.copyDestination?
        
        s.copyDestination.addItems s.selectedItems(), true  
        Flash.success("Copying #{count} places to #{s.copyDestination.name}.")
        s._deselectAll()

      s.planOptions = -> _( s.m.plans ).map().reject( (p) -> p.id == s.m.plan()?.id ).value()

      s.copySelectedText = ->
        count = s.selectedItems().length
        if count != 0 then "Copy #{count} To" else "Copy To"

      s.cancelOut = ->
        s.m.topBar = null
        s._deselectAll()

      s._deselectAll = ->
        i.selected = false for i in s.m.plan().items
        s.allSelected = false

      window.actions = s   
  }