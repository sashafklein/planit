angular.module("Common").service "Foursquare", ($http) ->
  class Foursquare
    @search: (near, query) -> $http.get('api/v1/foursquare/search', params: { near: near, query: query } )
    @parse: (exploreResponse) -> 
      return _.map exploreResponse.response?.groups?[0]?.items, (i) ->
        v = i.venue
        p = v.photos?.groups?[0]?.items?[0]
        a = 
          name: v.name
          names: _([v.name]).flatten().compact().value()
          image_url: if p then [ p['prefix'], p['suffix'] ].join("69x69") else null
          foursquare_icon: if v.categories then [v.categories[0].icon.prefix, v.categories[0].icon.suffix].join("bg_64") else null
          foursquare_id: v.id
          categories: _.map(v.categories || [], 'name')
          street_addresses: _([v.location?.address]).flatten().compact().value()
          sublocality: v.location?.neighborhood
          locality: v.location?.city
          region: v.location?.state
          country: v.location?.country
          lat: v.location?.lat
          lon: v.location?.lng

  return Foursquare