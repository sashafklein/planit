module Completers
  class GoogleMaps

    attr_reader :pip, :atts, :json
    def initialize(pip, atts)
      @pip, @atts = pip, atts
    end

    def complete
      find
      merge!
      { place: pip, photos: photos }
    end

    private

    def find
      @json = Services::GoogleJsonParser.new(url)
    end

    def merge!
      pip.set_val(:names, json.names, self.class)
      pip.set_val(:full_address, json.full_address, self.class)
      pip.set_val(:locality, json.locality, self.class)          
      pip.set_val(:region, json.region, self.class)          
      pip.set_val(:postal_code, json.postal_code, self.class)          
      pip.set_val(:country, json.country, self.class)          
      pip.set_val(:street_addresses, [json.street_address], self.class)
      pip.set_val(:website, json.website, self.class)          
      pip.set_val(:phones, [json.phone], self.class)          
      pip.set_val(:lat, json.lat, self.class)          
      pip.set_val(:lon, json.lon, self.class)            
    end

    def photos
      json.images.map{ |i| Image.new( source: i.credit, source_url: i.source, url: i.url ) }
    end

    def url
      "https://www.google.com/maps?q=#{query}&output=json"
    end

    def query
      "#{pip.name}, #{nearby}"
    end

    def nearby
      atts.nearby || [atts.locality, atts.region, atts.country].compact.join(", ")
    end

  end
end