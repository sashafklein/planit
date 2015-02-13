module Completers
  class ApiCompleter::Geolocate < ApiCompleter

    include RegexLibrary

    delegate :subregion, :region, :short_region, :country, :short_country, :lat, :lon, :locality, :sublocality, :postal_code, :full_address, to: :venue
    attr_accessor :pip, :atts, :take, :venue
    def initialize(pip, atts={}, take: [])
      @pip, @atts, @take = pip, atts, take
    end
    
    private

    def get_results(query)
      @venue = ApiVenue::GeolocateVenue.new( ( response_data(query) || response_data(pip.coordinate(', ')) || {} ).to_sh )
      @success = venue.found?
    end

    def response_data(query)
      Geocoder.search( query ).first.try(:data)
    end

    def response_hash
      { place: pip, success: @success.present? }
    end

    def update_location_basics(overwrite=false)
      set_vals fields: [:country, :region].select{ |k| take?(k) }
      update_locale(overwrite)
    end

    def update_locale(overwrite=false)
      set_vals fields: [:subregion, :locality, :sublocality].select{ |k| take?(k) }
    end

    def reverse_lat_lon_if_appropriate
      return if [lat, lon, pip.lat, pip.lon].any?(&:nil?)

      lat_possibly_reversed = pip.lat.points_of_similarity(lon) > 0
      lon_possibly_reversed = pip.lon.points_of_similarity(lat) > 0

      if lat_possibly_reversed && lon_possibly_reversed
        pip.flag( name: "Reversed LatLon", info: { pre_flip: pip.coordinate, geocoder: [lat, lon].join(":") } )
        set_vals fields: [:lat, :lon]
      end
    end

    def get_query
      @query = 
        if    pip.coordinate pip.coordinate(", ")
        elsif pip.street_address then [:street_address, :locality, :sublocality, :subregion, :region, :country].map{ |v| pip.send(v) }.reject(&:blank?).join(", ")
        else  pip.full_address
        end

      flag_query(@query)

      @query
    end

    def take?(key)
      take.include?(key)
    end
  end
end