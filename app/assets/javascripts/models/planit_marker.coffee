mod = angular.module('Models')
mod.factory 'PlanitMarker', ->

  class PlanitMarker

    @catIconFor: (metacategories) ->
      if metacategories
        return "<i class='fa fa-globe padding-top'></i>" if(metacategories[0] == 'Area')
        return "<span class='icon-directions-walk'></span>" if(metacategories[0] == 'Do')
        return "<span class='icon-local-bar'></span>" if(metacategories[0] == 'Drink')
        return "<span class='icon-local-restaurant'></span>" if(metacategories[0] == 'Food')
        return "<i class='fa fa-life-ring'></i>" if(metacategories[0] == 'Help')
        return "<i class='fa fa-money'></i>" if(metacategories[0] == 'Money')
        return "<i class='fa fa-globe'></i>" if(metacategories[0] == 'Other')
        return "<span class='icon-drink'></span>" if(metacategories[0] == 'Relax')
        return "<i class='fa fa-university xsm'></i>" if(metacategories[0] == 'See')
        return "<i class='fa fa-shopping-cart'></i>" if(metacategories[0] == 'Shop')
        return "<span class='icon-home'></span>" if(metacategories[0] == 'Stay')
        return "<i class='fa fa-exchange sm padding-bottom'></i>" if(metacategories[0] == 'Transit')
      return "<i class='fa fa-globe padding-top'></i>"

    @primaryPin: (place, show_popup = true) ->
      primaryMarker = L.marker(new L.LatLng(place.lat, place.lon), options={
        title: place.names[0],
        alt: place.names[0],
        placeObject: place,
        riseOnHover: true,
        properties: {
          placeObject: place,
        },
        icon: L.divIcon({
          className: 'default-map-div-icon',
          html: "<div class='default-map-icon-tab' id='pin-#{ place.id }'>#{ @catIconFor( place.meta_categories ) }<div class='arrow' /></div>",
          iconSize: null,
        }),
      })
      if show_popup
        primaryMarker.bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,8)})
      else
        primaryMarker

    @contextPin: (place) ->
      L.marker([place.lat, place.lon], {
        icon: L.divIcon({
          className: 'contextual-map-div-icon',
          html: "<div class='contextual-map-icon-tab' id='pin-#{ place.id }'>#{ @catIconFor( place.meta_categories ) }</div>",
          iconSize: null,
        })
      }).bindPopup("<a href='/places/#{place.id}'>#{ place.name() }</a>", {offset: new L.Point(0,3), className: 'mini-popup'})

  return PlanitMarker