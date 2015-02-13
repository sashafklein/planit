module Completers
  class ApiVenue::FoursquareExploreVenue < ApiVenue

    IMAGE_SIZE = '622x440'

    attr_accessor :json
    def initialize(json)
      @json = SuperHash.new json['venue']
    end

    def photos
      return [] unless photos = json.super_fetch( *['featuredPhotos', 'items'] )
      photos.map do |photo|
        [photo['prefix'], photo['suffix']].join(IMAGE_SIZE)
      end
    end   
    
    def website
      json['url']
    end

    def name
      json.name
    end

    def names
      [name].flatten
    end

    def phones
      [json.super_fetch( %w(contact phone) )].flatten
    end

    def street_addresses
      [json.super_fetch( %w(location address) )].flatten
    end

    def lat
      json.super_fetch %w(location lat)  
    end

    def lon
      json.super_fetch %w(location lng)
    end

    def country
      json.super_fetch %w(location country)
    end

    def region
      json.super_fetch %w(location state)
    end

    def locality
      json.super_fetch %w(location city)
    end

    def sublocality
      json.super_fetch %w(location neighborhood)
    end

    def full_address
      fa = json.super_fetch %w( location formattedAddress )
      fa ? fa.join(", ") : nil
    end

    def menu
      json.super_fetch %w( menu url )
    end

    def mobile_menu
      json.super_fetch %w( menu mobileUrl )
    end

    def foursquare_id
      json['id']
    end

    memoize :lat, :lon, :name, :names, :foursquare_id, :full_address, :locality, :region, :country, :menu, :mobile_menu, :website, :phones, :street_addresses, :photos
  end
end