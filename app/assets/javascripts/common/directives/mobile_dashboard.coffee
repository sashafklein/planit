angular.module("Common").directive 'mobileDashboard', (Mark, Place, Modal, $timeout, ErrorReporter, $sce, CurrentUser, QueryString, UserLocation, BarExpander) ->

  return {
    restrict: 'E'
    transclude: false
    replace: true
    templateUrl: "mobile_dashboard.html"

    link: (s, element) ->

      s.userId = CurrentUser.id

      # NAVIGATION

      s.loading = false
      s.pageIs = null
      s.pageWas = null
      s.$on '$locationChangeSuccess', (event, next) -> s.pageIs = QueryString.get()['mobile']
      s.goTo = (page=null) -> 
        s.pageWas = QueryString.get()['mobile']
        if page then QueryString.set({ mobile: page }) else QueryString.reset()
      s.cancel = -> 
        # Stop function?
        # if s.pageWas then s.goTo(s.pageWas) else s.goTo()
        s.loading = false

      s.tryGoToNearby = -> if s.LatLon then s.goTo('nearby') else 

      # ADD NEW

      $(".js-example-placeholder-multiple#guides").select2({ placeholder: "Add to Guide(s)" });

      s.canAdd = false
      s.checkAdd = -> 
        if s.placeName?.length > 1 && s.placeNearby?.length > 1
          s.canAdd = true
        else
          s.canAdds = false

      s.thereAlready = false
      s.there = -> s.thereAlready = !s.thereAlready

      s.submitAdd = ->
        if s.canAdd
          s.loading = true
          Place.complete({ user_id: s.userId, name: s.placeName, nearby: s.placeNearby })
            .success (response) ->
              if s.loading == true
                s.goTo('saved')
                $timeout(-> s.loading = false )
              else if s.loading == false
                markObj = new Mark({ id: response.id })
                markObj.destroy()
                  .error (response) -> ErrorReporter.report({ mark_id: response.id, context: 'Trying to delete a mark in mobileDashboard', api_path: markObj.objectPath() })
            .error (response) -> ErrorReporter.report({ user_id: s.userId, context: 'Trying to create a place & mark in mobileDashboard' })

      # SEARCH

      s.search = -> BarExpander.expandBar()

      # RECENT

      # s.markModal = new Modal('viewMarkPlace')
      # s.openPlace = (place_id) -> 
      #   Place.find( place_id )
      #     .success (response) -> 
      #       s.markModal.show({ place: response })
      #     .error (response) -> ErrorReporter.report({ place_id: place_id, context: 'Trying to find and then open a place in Mobile Dashboard'})

      # LOCATION / NEARBY

      UserLocation._getLocation()
      s.latLon = UserLocation.latLong

  }