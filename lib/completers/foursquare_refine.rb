module Completers
  class FoursquareRefine

    attr_accessor :fsid, :pip, :venue
    def initialize(pip)
      @pip, @fsid = pip, pip.foursquare_id
    end

    def complete
      return pip unless fsid.present?

      refine
      { place: pip, photos: venue.photos || [] }
    end

    private

    def refine
      get_venue
      merge!
    end

    def get_venue
      @venue = Venue.new HTTParty.get(full_fs_url)
    end

    def merge!
      return unless venue
      set_val :menu, venue.menu
      set_val :mobile_menu, venue.mobile_menu
      set_val :wifi, venue.wifi
      set_val :cross_street, venue.cross_street
      set_val :hours, venue.hours 
      set_val :categories, venue.categories
      set_val :reservations, venue.reservations 
      set_val :reservations_link, venue.reservations_link
      set_val :completion_steps, self.class.to_s.demodulize, true
    end

    def full_fs_url
      url = "#{ FoursquareExplore::FS_URL }/#{ fsid }?oauth_token=#{ FoursquareExplore.auth_token }"
      pip.flag(name: "API Query", details: "In #{self.class}", info: { query: url })
      url
    end

    def set_val(field, val, override=false)
      if !override && !pip.val(field) == false && pip.val(field).present?
        pip.flag( name: "Field Clash", details: "Ignored FoursquareRefine value.", info: { field: field, place: pip.val(field), venue: val} ) if pip.val(field) != val
      else
        pip.set_val field, val, self.class
      end
    end

    class Venue

      attr_accessor :json
      delegate :wifi, to: :json
      def initialize(json)
        @json = SuperHash.new( json['response'] == {} ? {} : json['response']['venue'] )
      end

      def hours
        format( json.hours )
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
        return [] unless venue_photos

        photo_list = venue_photos.items.first(30)
          .map{ |h| [h.prefix, h.suffix].join(FoursquareExploreVenue::IMAGE_SIZE) }

        photo_list.map do |photo|
          Image.where(url: photo).first_or_initialize(source: 'Foursquare')
        end
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
end