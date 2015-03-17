mod = angular.module("Models")
mod.factory 'BucketEventManager', (F, $timeout) ->

  class BucketEventManager

    constructor: (scope) ->
      @s = scope

    selectCluster: (e, args) =>
      return unless id = @_idFromEvent(e) || @_idFromArgs(args)
      id = @_id(target)
      @_markerAndLiForClusterId( @s.selectedClusterId = id ).addClass('highlighted')
      @_scrollToSidebarItem("c#{ id }")

    deselectCluster: =>
      @_markerAndLiForClusterId( @s.selectedClusterId ).removeClass('highlighted')
      @s.selectedClusterId = null

    selectPlace: (e, args) =>
      return unless id = @_idFromArgs(args) || @_idFromEvent(e)
      @_markerAndLiForPlaceId( @s.selectedPlaceId = id ).addClass('highlighted')
      @_scrollToSidebarItem("p#{ id }")
    
    deselectPlace: () =>
      @_markerAndLiForPlaceId( @s.selectedPlaceId ).removeClass('highlighted')
      @s.selectedPlaceId = null

    deselectAll: => @s.selectedClusterId = @s.selectedPlaceId = null

    redirect: (e, args) => 
      return alert("Redirect didn't work") unless id = @_idFromArgs(args)
      document.location.href = "/places/#{id}"

    # TODO - also seems to fire too many times?
    zoomToCluster: (e) => 
      e.stopPropagation()
      alert('Zoom!')

    _fullId: (target) -> $(target).attr('id')
    _id: (target) -> @_fullId(target).slice(1)
    _idFromArgs: (args) -> args?.leafletEvent?.target?.options?.id
    _idFromEvent: (e) -> if e.target? then @_id @_climbToCorrectElement(e.target) else null

    # TODO -- not working, I think because scrolling seems disabled for the sidebar
    _scrollToSidebarItem: (id) -> 
      $timeout ->
        $('#in-view-list').animate({
          scrollTop: $("##{id}").offset().top - $('#top-of-list').offset().top
        }, 0)

    _climbToCorrectElement: (target) ->
      if @_hasValidId(target)
        target
      else
        @_climbToCorrectElement(target.parentElement)  

    _hasValidId: (target) -> 
      id = @_fullId(target)
      id && ( _.some(['p','c'], ( (char) -> id[0] == char ) ) ) && ( id.slice(1) == String( parseInt(id.slice(1)) ) )

    _markerAndLiForPlaceId: (id) -> $(".default-map-icon-tab\#p#{id}, .bucket-list-li.place-li\#p#{id}")
    _markerAndLiForClusterId: (id) -> $(".cluster-map-icon-tab\#c#{id}, .bucket-list-li.cluster-li\#c#{id}")

    _ClusterDivs: -> [".cluster-map-icon-tab", ".bucket-list-li.cluster-li"]
    _MarkerDivs: -> [".bucket-list-li.place-li"]
    _EditDivs: -> [".edit-place", ".edit-places"]

    _setEventBehavior: (oType, eventType, screenWidthMethodHash) ->
      return unless methodToFire = screenWidthMethodHash[@s.screenWidth]
      attachBehavior = (div, eventType, methodToFire) -> $(div).on( eventType, methodToFire )

      if !_.some(["Cluster", "Edit"], (w) -> oType == w )
        @s.$on( "leafletDirective#{oType}.#{eventType}", methodToFire )

      if (divs = @["_#{oType}Divs"])?
        for div in divs()
          if $(div).length
            attachBehavior(div, eventType, methodToFire)
          else
            $timeout( ( => attachBehavior(div, eventType, methodToFire) ), 400 )
        
        

    _eventLogic: ->
      Marker: 
        click: { mobile: @selectPlace, web: @redirect }
        mouseover: { web: @selectPlace }
        mouseout: { web: @deselectPlace }
        dblclick: { mobile: @redirect }
      Cluster:
        click: { mobile: @selectCluster, web: @zoomToCluster }
        dblclick: { mobile: @zoomToCluster }
        mouseover: { web: @selectCluster }
        mouseout: { web: @deselectCluster }
      Map: 
        moveend: { mobile: @s.recalculateInView, web: @s.recalculateInView }
        click: { mobile: @deselectAll }

    _setObjectBehavior: (behaviorList, objectType) ->
      _.forEach behaviorList, (screenWidthMethodHash, eventType) =>
        @_setEventBehavior(objectType, eventType, screenWidthMethodHash)

    _setMouseEvents: (eventLogic) -> 
      _.forEach eventLogic, (behaviorList, objectType) =>
        @_setObjectBehavior(behaviorList, objectType)

      @_eventsSet = true

    resetClusterEvents: () -> 
      $timeout( (=> @_setMouseEvents( _( @_eventLogic() ).pick('Cluster', 'Marker').value() ) ), 400 )
      
    waitAndSetMouseEvents: -> $timeout( ( => @_setMouseEvents( @_eventLogic() ) ), 400 )

  return BucketEventManager