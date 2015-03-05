module Completers
  class ApiCompleter::FoursquareExplore < ApiCompleter
    # Old OAuth "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR"
    FS_URL = 'https://api.foursquare.com/v2/venues'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :pip

    attr_accessor :pip, :venues, :venue, :geocoded, :photos, :alternate_nearby, :response
    def initialize(pip, attrs={}, take: nil)
      @pip = pip
      @alternate_nearby = attrs[:nearby]
      @photos = []
      @success = false
    end

    def self.auth
      "client_id=O4DVODVMFR3JT0H35DXYXCT5O4TEB0AESQKPI3N204ZCJ21U&client_secret=DXCS3CPUYRSHKYK0TV3SVBPDH53X2CR4JTJMKFD0NVI13QKF&v=#{ Date.today.strftime("%Y%m%d") }"
    end

    def complete
      unless sufficient_to_fetch?
        pip.flag(name: "Insufficient Atts for FoursquareExplore", info: { missing: pip.attrs.slice(:lat, :lon, :locality, :region, :country).select_val(&:blank?).map{ |k, v| k } } )
        return return_hash
      end

      explore
      return_hash
    end

    def sufficient_to_fetch?
      (name.present? || street_address.present?) && (nearby || (lat && lon))
    end

    private

    def explore
      get_venues!
      pick_venue
      
      pip.question!(class_name) unless @success = ( venue.present? && !pip.unsure.include?(class_name) && venue.seems_legit? )

      merge!
    end

    def nearby
      @nearby ||= pip.generate_nearby || alternate_nearby
    end

    def get_venues!
      @response = HTTParty.get(full_fs_url).to_sh

      @venues = @response.super_fetch( :response, :groups, 0, :items ).map do |item|
        ApiVenue::FoursquareExploreVenue.new(item)
      end
    rescue => e
      @venues ||= []
      flag_failure(query: full_fs_url, response: @response, error: e)
    end

    def sort_venues
      @venues.sort!{ |a, b| b.matcher(pip).ll_fit <=> a.matcher(pip).ll_fit }
      pip.flag( name: "Foursquare Explore Results", info: @venues.map{ |v| { name: v.name, fsid: v.foursquare_id } } )
    end
    
    def atts_to_merge
      [:website, :locality, :country, :region, :lat, :lon, :menu, :mobile_menu, :foursquare_id, :names, :street_addresses, :phones, :full_address, :sublocality, :photos]
    end

    def merge!
      pip.flag( name: "Name-Lat/Lon Clash", details: "Taking information from identically named, distant FoursquareExplore data.", info: { name: venue.name, venue: { lat: venue.lat, lon: venue.lon }, place: { lat: pip.lat, lon: pip.lon } } ) if venue && venue.matcher(pip).name_stringency == 0.99
      super
    end

    def return_hash
      { place: pip, success: @success }.to_sh
    end
    
    def nearby_parameter
      URI.escape( coordinate ? "ll=#{coordinate(',')}" : "near=#{nearby}" )
    end

    def query
      URI.escape( name || street_address )
    end

    def full_fs_url
      return @full_fs_url if @full_fs_url
      url = "#{ FS_URL }/explore?#{ nearby_parameter }&query=#{ query }&#{ self.class.auth }&venuePhotos=1"
      flag_query(url)
      url
    end
  end
end