mod = angular.module("Models")
mod.factory "Place", (BaseModel, BasicOperators, $http) ->
  
  class Place extends BaseModel

    constructor: (_properties) ->
      properties = _.clone(_properties)
      _.extend(this, _properties)
      @images = [{ url: @image_url, source: 'Foursquare'}] if !@images?.length && @image_url

    @class: "Place"
    class: Place.class

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

    @search: (query, nearby) -> $http.get("#{@basePath}/search", { params: { q: query, n: nearby } } )
    @complete: (obj) -> 
      $http.post "/api/v1/users/#{obj.user_id}/marks/create", 
        mark: { place: { name: obj.name, nearby: obj.nearby } }

    url: -> "/places/#{@id}"
    name: -> @names[0]
    hasImage: -> @images.length > 0 && @images[0].url

    localeDetails: -> if @locale? then @locale else _([@street_addresses[0], @sublocality, @locality, @region, @country]).compact().uniq().value().slice(0,2).join(", ")
    
    @_sublocality = (places) -> _(places).map('sublocality').compact().uniq().value()
    @_locality = (places) -> _(places).map('locality').compact().uniq().value()
    @_region = (places) -> _(places).map('region').compact().uniq().value()
    @_country = (places) -> _(places).map('country').compact().uniq().value()
    
  return Place