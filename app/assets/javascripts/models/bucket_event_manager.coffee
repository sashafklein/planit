mod = angular.module("Models")
mod.factory 'BucketEventManager', (F) ->

  class BucketEventManager

    constructor: (scope) ->
      @s = scope

    selectCluster: (e, args) =>
      return unless target = @_climbToCorrectElement(e.target)
      id = @_id(target)
      @_markerAndLiForClusterId( @s.selectedClusterId = id ).addClass('highlighted')

    deselectCluster: =>
      @_markerAndLiForClusterId( @s.selectedClusterId ).removeClass('highlighted')
      @s.selectedClusterId = null

    selectPlace: (e, args) =>
      return unless place = args?.leafletEvent?.target?.options
      @_markerAndLiForPlaceId( @s.selectedPlaceId = place.id ).addClass('highlighted')
    
    deselectPlace: () =>
      @_markerAndLiForPlaceId( @s.selectedPlaceId ).removeClass('highlighted')
      @s.selectedPlaceId = null

    deselectAll: => @s.selectedClusterId = @s.selectedPlaceId = null

    zoomToCluster: (e) => 
      e.stopPropagation()
      alert('Zoom!')

    _fullId: (target) -> $(target).attr('id')
    _id: (target) -> @_fullId(target).slice(1)

    _climbToCorrectElement: (target, e) ->
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

    _setMouseEvents: -> 
      return unless @s.mapRendered() && $(".bucket-list-li.cluster-li").length
      _( @_eventLogic() ).forEach( (behaviorList, objectType) => 
        @_setObjectBehavior(behaviorList, objectType)
      ).value()
      @_eventsSet = true

    waitAndSetMouseEvents: -> F.stagger( ( => @_setMouseEvents() ), 100, 10, ( => @_eventsSet ) )

  return BucketEventManager