module Scrapers
  module FoursquareMod

    # PAGE SETUP

    class Item < Foursquare

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url,
          user_data: {
            foursquare_user_id: foursquare_user_id,
            first_name: foursquare_user_first_name,
            last_name: foursquare_user_last_name,
            gender: foursquare_user_gender,
            hometown: foursquare_user_homecity,
            facebook_user_id: facebook_user_id,
            email: email,
          }
        }
      end

      # OPERATIONS

      def data
        [{
          place:{
            foursquare_id: venue_json.id,
            name: venue_json.name,
            categories: safe_categories( venue_json.categories ),
            lat: venue_json.location.lat,
            lon: venue_json.location.lng,
            street_address: venue_json.location.address,
            sublocality: venue_json.location.neighborhood,
            locality: venue_json.location.city,
            state: venue_json.location.state,
            country: venue_json.location.country,
            postal_code: venue_json.location.postalCode,
            phones: safe_phones( venue_json.contact ),
            website: venue_json.url,
          },
          mark: {
            notes: tip_json.text,
          },
          sources: {
            full_url: ( tip_json.url if !tip_json.url.include?('foursquare') ),
            name: tip_json.user.firstName,
          }
        }.merge(global_data)]
      end

      # JSON

      def json_bundle
        return @json_bundle unless !@json_bundle
        return @json_bundle = page.css('script').select{ |s| s.inner_html.scan(/fourSq\.views\.TipPage\.init/).flatten.first }.first.text
      end

      def tip_json
        return @tip_json unless !@tip_json
        from_first_bracket = json_bundle.split(/fourSq\.views\.TipPage\.init[(][{]tip[:]\s*/).last
        to_parse = get_parseable_hash from_first_bracket
        return @tip_json = JSON.parse( to_parse ).to_sh
      end

      def venue_json
        return @venue_json unless !@venue_json
        from_first_bracket = json_bundle.split(/[}][,]\s*venue[:]\s*/).last
        to_parse = get_parseable_hash from_first_bracket
        return @venue_json = JSON.parse( to_parse ).to_sh
      end

      # NO-ERROR FUNCTIONS

      def safe_categories(categories)
        if categories.is_a? Object
          categories.map{ |c| c.name }
        end
      end

      def safe_phones(phones)
        if phones.is_a? Object
          phones.select{ |k,v| k == 'phone' }.map{ |k,v| v }
        end
      end

      # USER DATA

      def foursquare_user_id
        return @user_id unless !@user_id
        @user_id = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"(.*?)"/).flatten.uniq.first
      end

      def foursquare_user_first_name
        return @first_name unless !@first_name
        @first_name = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"(.*?)"/).flatten.uniq.first
      end

      def foursquare_user_last_name
        return @last_name unless !@last_name
        @last_name = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"#{foursquare_user_first_name}","lastName":"(.*?)"/).flatten.uniq.first
      end

      def foursquare_user_gender
        return @gender unless !@gender
        @gender = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"#{foursquare_user_first_name}","lastName":"#{foursquare_user_last_name}",.*?"gender":"(.*?)"/).flatten.uniq.first
      end

      def foursquare_user_homecity
        return @homecity unless !@homecity
        @homecity = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"#{foursquare_user_first_name}","lastName":"#{foursquare_user_last_name}","homeCity":"(.*?)"/).flatten.uniq.first
      end

      def facebook_user_id
        return @facebook unless !@facebook
        @facebook = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"#{foursquare_user_first_name}","lastName":"#{foursquare_user_last_name}",.*?"facebook":"(.*?)"/).flatten.uniq.first
      end

      def email
        return @email unless !@email
        @email = page.inner_html.scan(/[{]USER_PROFILE: [{]"id":"#{foursquare_user_id}","firstName":"#{foursquare_user_first_name}","lastName":"#{foursquare_user_last_name}",.*?"email":"(.*?)"/).flatten.uniq.first
      end

    end
  end
end