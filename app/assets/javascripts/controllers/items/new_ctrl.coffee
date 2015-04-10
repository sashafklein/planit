angular.module("Controllers").controller 'Items.NewCtrl', ($scope, User, ErrorReporter, CurrentUser, Plan, Foursquare, Item, Place) ->
  s = $scope
  s.preexisting = []

  s.getLists = ->
    User.findPlans( CurrentUser.id )
      .success (response) ->
        s.visibleLists = s.lists = Plan.generateFromJSON(response)
      .error (response) ->
        ErrorReporter.report({ context: 'Items.NewCtrl getLists'}, "Something went wrong! We've been notified.")

  s.getListItems = ->
    return unless s.list?
    Item.where({ plan_id: s.list.id })
      .success (response) ->
        s.preexisting = Place.generateFromJSON( _.map(response, (i) -> i.mark.place) )
      .error (response) ->
        ErrorReporter.report({ context: 'Items.NewCtrl getListItems', list_id: s.list.id}, "Something went wrong! We've been notified.")

  s.resetList = () ->
    s.getLists()
    s.list = s.listQuery = s.options = s.placeName = s.placeNearby = null
    s.preexisting = []

  s.setList = (list) ->
    if list
      s._installList(list)
    else
      Plan.create( plan_name: s.listQuery )
        .success (response) ->
          s._installList Plan.generateFromJSON(response)
        .error (response) ->
          ErrorReporter.report({ context: 'Items.NewCtrl Plan.create', plan_name: s.listQuery}, "Something went wrong! We've been notified.")

  s._installList = (list) ->
    s.list = list
    s.getListItems()
    s.visibleLists = []
    s.listQuery = list.name

  s.search = -> s._searchFunction() if s.placeName && s.placeNearby

  s._searchFunction = _.debounce( (-> s._makeSearchRequest() ), 500 )

  s._makeSearchRequest = ->
    Foursquare.search(s.placeNearby, s.placeName)
      .success (response) ->
        s.options = Place.generateFromJSON(response)
      .error (response) ->
        ErrorReporter.report({ context: 'Items.NewCtrl search', near: s.placeNearby, query: s.placeName }, "Something went wrong! We've been notified.")        

  s.addItem = (option) ->
    s.list.addItemFromPlaceData(option)
      .success (response) ->
        s.preexisting.unshift Place.generateFromJSON(response) 
        s.options = []
        s.placeName = null
      .error (response) ->
        ErrorReporter.report({ context: 'Items.NewCtrl addItem', option: JSON.stringify(option), plan: JSON.stringify(s.list) }, "Something went wrong! We've been notified.")        

  window.s = s