mod = angular.module("Models")
mod.factory "Place", ($resource, BaseModel) ->
  
  class Place extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Place, json)
    @basePath: '/api/v1/places'

    @lowestCommonArea: (places) ->
      sublocalities = @_sublocality(places)
      localities = @_locality(places)
      regions = @_region(places)
      countries = @_country(places)
      if localities.length == 1
        area = @_geoSelectAndJoin( sublocalities )
        area ||= localities[0]
      else
        area ||= @_geoSelectAndJoin( localities, 2 )
        area ||= @_geoSelectAndJoin( regions )
        area ||= @_geoSelectAndJoin( countries, 2 )
        area ||= @_geoSelectAndJoin( @_globalRegion(places) )
        area ||= @_geoSelectAndJoin( @_continent(places) )

    url: -> "/places/#{@id}"
    name: -> @names[0]
    hasImage: -> @images.length > 0 && @images[0].url
    
    @_geoSelectAndJoin = (list, max=3) ->
      return null if !list || list.length == 0 || list.length > 3
      if list.length == 1
        list[0]
      else if list.length == 2 && max > 1
        list.join(" & ")
      else if list.length == 3 && max > 2
        [[list[0],list[1]].join(", "),list[2]].join(" & ")
      else if list.length == 3 && max > 3
        [[list[0],list[1],list[2]].join(", "),list[3]].join(" & ")

    @_sublocality = (places) -> _(places).map('sublocality').compact().uniq().value()
    @_locality = (places) -> _(places).map('locality').compact().uniq().value()
    @_region = (places) -> _(places).map('region').compact().uniq().value()
    @_country = (places) -> _(places).map('country').compact().uniq().value()

    @_globalRegion = (places) -> return null
    @_continent = (places) -> return null

  return Place