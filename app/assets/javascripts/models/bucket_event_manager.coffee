mod = angular.module("Models")
mod.factory 'BucketEventManager', (F, $timeout) ->

  class BucketEventManager

    constructor: (scope) ->
      @s = scope

    selectCluster: (e, args) =>
      return unless target = @_climbToCorrectElement(e.target)
      id = @_id(target)
      @_markerAndLiForClusterId( @s.selectedClusterId = id ).addClass('highlighted')
      @_scrollToSidebarItem("c#{ id }")

    deselectCluster: =>
      @_markerAndLiForClusterId( @s.selectedClusterId ).removeClass('highlighted')
      @s.selectedClusterId = null

    selectPlace: (e, args) =>
      return unless place = args?.leafletEvent?.target?.options
      @_markerAndLiForPlaceId( @s.selectedPlaceId = place.id ).addClass('highlighted')
      @_scrollToSidebarItem("p#{ place.id }")
    
    deselectPlace: () =>
      @_markerAndLiForPlaceId( @s.selectedPlaceId ).removeClass('highlighted')
      @s.selectedPlaceId = null

    deselectAll: => @s.selectedClusterId = @s.selectedPlaceId = null

    redirect: (e, args) => 
      return alert("Redirect didn't work") unless id = args?.leafletEvent?.target?.options?.id
      document.location.href = "/places/#{id}"

    # TODO - also seems to fire too many times?
    zoomToCluster: (e) => 
      e.stopPropagation()
      alert('Zoom!')

    _fullId: (target) -> $(target).attr('id')
    _id: (target) -> @_fullId(target).slice(1)

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
    _EditDivs: -> [".edit-place", ".edit-places"]

    _setEventBehavior: (oType, eventType, screenWidthMethodHash) ->
      return unless methodToFire = screenWidthMethodHash[@s.screenWidth]
      if _(["Cluster", "Edit"]).some( (w) -> oType == w )
        $(div)[eventType]( methodToFire ) for div in $( @["_#{oType}Divs"]?() )
      else 
        @s.$on( "leafletDirective#{oType}.#{eventType}", methodToFire )
        

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
      _( behaviorList ).forEach( (screenWidthMethodHash, eventType) =>
        @_setEventBehavior(objectType, eventType, screenWidthMethodHash)
      ).value()

    _setMouseEvents: (eventLogic) -> 
      _( eventLogic ).forEach( (behaviorList, objectType) => 
        @_setObjectBehavior(behaviorList, objectType)
      ).value()
      @_eventsSet = true

    resetClusterEvents: -> @_setMouseEvents( _( @_eventLogic() ).pick('Cluster') ) 
      
    waitAndSetMouseEvents: -> $timeout( ( => @_setMouseEvents( @_eventLogic() ) ), 400 )

  return BucketEventManager