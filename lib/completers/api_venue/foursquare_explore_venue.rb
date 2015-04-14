module Completers
  class ApiVenue::FoursquareExploreVenue < ApiVenue

    IMAGE_SIZE = '622x440'

    attr_accessor :json
    def initialize(incoming)
      @json = SuperHash.new incoming['venue']
    end

    def photos
      return [] unless photos = json.super_fetch( *['featuredPhotos', 'items'] )
      list = photos.map do |photo|
        [photo['prefix'], photo['suffix']].join(IMAGE_SIZE)
      end
      { photos: list, source: "Foursquare" }
    end

    def images
      return [] unless photos = json.super_fetch( *['featuredPhotos', 'items'] )
      photos.map{ |photo| { url: [photo['prefix'], photo['suffix']].join(IMAGE_SIZE), source: 'Foursquare' } }
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

    def categories
      (cats = json.categories || []).map(&:name)
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

    def seems_legit?
      check_ins && check_ins > 50 && photos.any?
    end

    def image_url
      photo = json.super_fetch( :photos, :groups, 0, :items, 0 )
      return unless photo
      [ photo['prefix'], photo['suffix'] ].join("69x69")
    end

    def icon
      cats = json.categories || []
      [cats.first.icon.prefix, cats.first.icon.suffix].join("bg_64") if cats.any?
    end

    private

    def check_ins
      json.super_fetch %w( stats checkinsCount )
    end

    memoize :lat, :lon, :name, :names, :foursquare_id, :full_address, :locality, :region, :country, :menu, :mobile_menu, :website, :phones, :street_addresses, :photos, :image_url
  end
end