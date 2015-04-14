angular.module('Controllers').controller 'Plans.EditCtrl', ($scope, ErrorReporter, Plan, Item, $http, $q) ->

  s = $scope

  s.getPlan = (id) ->
    Plan.find(id)
      .success (response) ->
        s.plan = Plan.generateFromJSON(response)
        s._getItems()
        s._getManifestItems()
      .error (response) ->
        ErrorReporter.defaultReport( context: 'Plans.EditCtrl getPlan', plan_id: id )

  s.addToManifest = (itemIndex, insertIndex=0) -> 
    item = s.items[itemIndex]
    s._runRequest( ( -> s.plan.addToManifest(item, insertIndex) ), 'addToManifest', { item_id: item.id })

  s.removeFromManifest = (itemIndex) ->
    item = s.manifestItems[itemIndex]
    s._runRequest( ( -> s.plan.removeFromManifest( item, itemIndex ) ), 'removeFromManifest', {item_id: item.id, remove_index: itemIndex} )

  s.moveInManifest = (from, to) ->
    s._runRequest( ( -> s.plan.moveInManifest(from, to) ), 'moveInManifest', { from: from, to: to } )


  s._runRequest = (request, name='', extraReporting={}) ->
    request()
      .success (response) ->
        s._resetManifestItems(response)
      .error (response) ->
        ErrorReporter.defaultReport _.extend({context: "Plans.EditCtrl #{name}", plan_id: s.plan.id}, extraReporting) 

  s._resetManifestItems = (response) ->
    s.plan.manifest = response
    newManifestItems = []
    for item, index in s.plan.manifest
      if found = s._findItem(item)
        newManifestItems.push _.extend(found, { $$hashKey: "object:#{index}", index: index })
    s.manifestItems = newManifestItems

  s._findItem = (manifestItem) -> 
    item = _.find(s.items, (i) -> s._identical(i, manifestItem)) || _.find(s.manifestItems, (i) -> s._identical(i, manifestItem) || {})
    return null unless item?.class
    s._objectClasses[item.class].generateFromJSON( _.extend({}, item) )

  s._identical = (item1, item2) -> item1.class == item2.class && item1.id == item2.id

  s._getManifestItems = ->
    s.manifestItems = []
    _(s.plan.manifest).map( (item, index) -> 
      ( -> s._getManifestItem( item, index ) )
    ).reduce( ( (promise, next) -> promise.then(next) ), $q.when() )

  s._getManifestItem = (item, index) ->
    classObj = s._objectClasses[item.class]
    classObj.find(item.id)
      .success (response) ->
        s.manifestItems.push _.extend( classObj.generateFromJSON(response), { index: index } )
      .error (response) ->
        ErrorReporter.defaultReport( context: 'Plans.EditCtrl getManifestItems', plan_id: s.plan.id, item_id: item.id )

  s._getItems = ->
    s.plan.items()
      .success (response) ->
        s.items = Item.generateFromJSON( response )
      .error (response) ->
        ErrorReporter.defaultReport( context: 'Plans.EditCtrl getItems', plan_id: s.plan.id )        

  s._objectClasses = { "Item": Item }

  window.s = s
