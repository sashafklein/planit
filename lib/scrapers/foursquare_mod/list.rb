module Scrapers
  module FoursquareMod

    # PAGE SETUP

    class List < Foursquare

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url,
          plan:{
            name: ( list_name || list_json.name ),
            owner: {
              first_name: list_json.firstName,
              last_name: list_json.user.lastName,
              gender: list_json.user.gender,
              foursquare_user_id: list_json.user.id,
            },
            created_at: list_created_at,
            foursquare_list_id: ( foursquare_list_id || list_json.id ),
            public: list_json.public,
          },
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

      # PAGE 

      # OPERATIONS

      def activity_group(section)
        list_json.listItems.items
      end

      def activity_data(activity, activity_index)
        {
          place: {
            foursquare_id: activity.venue.id,
            name: activity.venue.name,
            categories: safe_categories( activity.venue.categories ),
            lat: activity.venue.location.lat,
            lon: activity.venue.location.lng,
            street_address: activity.venue.location.address,
            sublocality: activity.venue.location.neighborhood,
            locality: activity.venue.location.city,
            region: activity.venue.location.state,
            country: activity.venue.location.country,
            postal_code: activity.venue.location.postalCode,
            phones: safe_phones( activity.venue.contact ),
            website: activity.venue.url,
          },
          mark: {
            notes: ( activity.tip.text if activity.tip ),
          },
          sources: {
            full_url: ( activity.tip.url if activity.tip && activity.tip.url && !activity.tip.url.include?('foursquare') ),
            name: ( activity.tip.user.firstName if activity.tip ),
          }
        }
      end

      # JSON

      def list_json
        return @list_json unless !@list_json
        script = page.css('script').select{ |s| s.inner_html.scan(/fourSq\.views\.ListPage\.init/).flatten.first }
        from_first_bracket = script.first.text.split(/listJson[:]\s*/).last
        to_parse = get_parseable_hash( from_first_bracket )
        return @list_json = JSON.parse( to_parse ).to_sh
      end

      # PLAN DATA

      def list_name
        h1 = page.css("#listDetails h1").text
        return h1 if url.include?( h1.downcase.split(" ").join("-") )
        return nil
      end

      def foursquare_list_id
        attempt_one = page.inner_html.scan(/listId: '(.*?)'/).flatten.first
        attempt_two = page.inner_html.scan(/listJson: [{]"id":"(.*?)",/).flatten.first
        attempt_three = list_json.id
        in_url = [attempt_one,attempt_two].compact.uniq.select{ |id| url.include?(id) }
        return in_url.length == 1 ? in_url.first : nil
      end

      def list_created_at
        json = list_json.createdAt
        return nil unless json.is_a? Integer
        timestamp = Time.at list_json.createdAt
        return timestamp.strftime('%Y-%m-%d')
      rescue ; nil
      end

      def list_owner_data
        usericon = page.css("#listUserIcon").css('img').first
      end 

      def list_owner_name
        list_owner_data.attr("alt")
      end

      def list_owner_avatar
        list_owner_data.attr("src").value()
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