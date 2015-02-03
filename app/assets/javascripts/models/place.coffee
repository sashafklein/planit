mod = angular.module("Models")
mod.factory "Place", ($resource, BaseModel, BasicOperators) ->
  
  class Place extends BaseModel
    @generateFromJSON: (json) -> BaseModel.generateFromJSON(Place, json)
    @basePath: '/api/v1/places'

    @lowestCommonArea: (places) ->
      sublocalities = @_sublocality(places)
      localities = @_locality(places)
      regions = @_region(places)
      countries = @_country(places)
      area = BasicOperators.commaAndJoin( sublocalities ) if localities.length == 1
      area ||= localities[0] if localities.length == 1
      area ||= BasicOperators.commaAndJoin( localities, 2 )
      area ||= BasicOperators.commaAndJoin( regions )
      area ||= BasicOperators.commaAndJoin( countries, 2 ) unless _.contains(countries, "United States")
      return area

    url: -> "/places/#{@id}"
    name: -> @names[0]
    hasImage: -> @images.length > 0 && @images[0].url
    
    @_sublocality = (places) -> _(places).map('sublocality').compact().uniq().value()
    @_locality = (places) -> _(places).map('locality').compact().uniq().value()
    @_region = (places) -> _(places).map('region').compact().uniq().value()
    @_country = (places) -> _(places).map('country').compact().uniq().value()

  return Place