module Scrapers
  module AirbnbMod

    # PAGE SETUP

    class Itinerary < Airbnb

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          # site_name: site_name,
        }
      end

      # PAGE 
      
      def data
        [{
          place: {
            name: trim( de_tag( name ) ) + " (Airbnb)",
            full_address: full_address,
            category: category,
            lat: lat,
            lon: lon,
          },
          item: {
            cost: cost,
            confirmation_code: confirmation_code,
            start_date: start_date,
            end_date: end_date,
            guests: guests,
            nights: nights,
            host_directions: host_directions,
            confirmation_url: @url,
            # host_name: host_name,
            # email: trim( email ),
            # phone: trim( phone ),
            # check_in_time
            # check_out_time
          }
        }.merge(global_data)]
      end

      # OPERATIONS

      def room_number
        page.inner_html.scan(%r!#{airbnb_rooms_link_find_room_no}!).flatten.first ; rescue ; nil
      end

      def host_id
        page.inner_html.scan(%r!#{airbnb_host_link_find_user_id}!).flatten.first ; rescue ; nil
      end

      def host_details
        parse = get_host
        parse.delete_at(0)
        trim( de_tag ( parse.join(', ') ) ) ; rescue ; nil
      end

      def get_host
        page.css("a[@href='/users/show/#{host_id}']").first.parent.parent.inner_html.gsub(/\n/, " ").split("</strong>")[1].split("<br>") ; rescue ; nil
      end

      def name
        page.css("a[@href='/rooms/#{room_number}']").first.text ; rescue ; nil
      end

      def get_address
        page.css("a[@href='/rooms/#{room_number}']").first.parent.parent.inner_html.gsub(/\n/, " ").split("</strong>")[1].split("<br>") ; rescue ; nil
      end

      def full_address
        parse = get_address
        parse.delete_at(0)
        trim( parse.join(', ') ) ; rescue ; nil
      end

      def start_date
        page.css("strong:contains('Check In')").first.parent.css('.h4').first.inner_html ; rescue ; nil
      end

      def end_date
        page.css("strong:contains('Check Out')").first.parent.css('.h4').first.inner_html ; rescue ; nil
      end

      def nights
        page.css(".text-muted:contains('Nights')").first.parent.css('.h4').first.inner_html ; rescue ; nil
      end

      def guests
        page.css(".text-muted:contains('Guests')").first.parent.css('.h4').first.inner_html ; rescue ; nil
      end

      def cost
        page.css(".receipt-label:contains('Total')").first.next_element.inner_html ; rescue ; nil
      end

      def host_directions
        trim( de_tag( page.css('h4:contains("s Directions")').first.parent.inner_html ) ) ; rescue ; nil
      end

      def confirmation_code
        trim( de_tag( page.css("div:contains('Confirmation Code:')").last.inner_html.split('Confirmation Code:')[1] ) ) ; rescue ; nil
      end

      #NEEDSFOLLOWUP
      # def phone
      #   [] ; rescue ; nil
      # end

      def site_name
        "Airbnb"
      end

      def category
        ["lodging"]
      end

      def private
        true
      end

      def map_string
        container = page.inner_html.scan(%r!#{static_map_src}!).flatten.first ; rescue ; nil
      end

      def lat
        map_string.split("markers=")[1].split("&")[0].split("%2C")[0] ; rescue ; nil
      end

      def lon
        map_string.split("markers=")[1].split("&")[0].split("%2C")[1] ; rescue ; nil
      end

    end
  end
end