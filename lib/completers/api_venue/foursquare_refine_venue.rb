module Completers
  class ApiVenue::FoursquareRefineVenue < ApiVenue

    attr_accessor :json
    delegate :wifi, to: :json
    def initialize(json)
      @json = SuperHash.new( json['response'] == {} ? {} : json['response']['venue'] )
    end

    def found?
      json.any?
    end

    def hours
      format( json.hours ) || {}
    end

    def cross_street
      json.super_fetch :location, :crossStreet
    end

    def menu
      json.super_fetch :menu, :url
    end

    def mobile_menu
      json.super_fetch :menu, :mobileUrl
    end

    def categories
      Array( json.categories ).flatten.map{ |c| c['name'] }
    end

    def street_addresses
      [ json.super_fetch(:location, :address) ].flatten.compact
    end

    def reservations
      return true if reservations_link.present?

      res = json.attributes.groups.find{ |g| g.type == 'reservations' }
      val = res ? res.to_sh.items.first.displayValue : 'No'
      val == 'No' ? false : true
    end

    def reservations_link
      json.super_fetch :reservations, :url
    end

    def photos
      venue_photos = json.photos.groups.find{ |h| h['type'] == 'venue' }

      photo_list = venue_photos.items.first(30)
        .map{ |h| [h.prefix, h.suffix].join(FoursquareExploreVenue::IMAGE_SIZE) }

      { photos: photo_list, source: 'Foursquare' }
    rescue 
      nil
    end

    private

    def format(hours)
      return nil unless hours

      new_hours = {}
      hours.timeframes.each do |tf|
        Array(tf.days.split(", ")).flatten.map(&:downcase).each do |day|
          new_hours[day] = tf.open.map{ |block| parse_time(block.renderedTime) } 
        end
      end

      Services::TimeConverter.convert_hours(new_hours)
    end

    def parse_time(rendered_time)
      rendered_time.split( String::LONG_DASH ).map{ |t| numericize(t) }.flatten
    end

    def numericize(time)
      case time
      when 'Noon' then '1200'
      when 'Midnight' then '2400'
      when '24 Hours' then ['0000', '0000']
      else time
      end
    end
  end
end