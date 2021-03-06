module Scrapers
  module TravelandleisureMod

    # PAGE SETUP

    class SingleItem < Travelandleisure

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url, 
        }
      end

      # PAGE 
      
      def data
        [{
          place:{
            name: name,
            lat: marker_json.latitude,
            lon: marker_json.longitude,
            full_address: full_address,
            phone: phone,
            website: website,
            email: email,
            category: category,
            price_note: price_note,
            hours_note: hours_note,
            # images: images,
            # lat: lat,
            # lon: lon,
          },
        }.merge(global_data)]
      end

      # JSON MATERIAL

      def json_bundle
        return @json_bundle unless !@json_bundle
        return @json_bundle = page.css('script').select{ |s| s.inner_html.scan(/Drupal\.settings\, \{/).flatten.first }.first.text
      end

      def marker_json
        return @marker_json unless !@marker_json
        from_first_bracket = json_bundle.split(/\"markers\"\:\[/).last
        to_parse = get_parseable_hash from_first_bracket
        return @marker_json = JSON.parse( to_parse ).to_sh
      end

      # OPERATIONS

      def name
        [
          trim( page.css("h1").first.text ),
          de_tag( marker_json.text )
        ].compact.uniq.first
      rescue ; nil
      end

      def full_address
        trim( de_tag( page.css(".ask-question").first.text ) )
      rescue ; nil
      end

      def phone
        trim( de_tag( page.css("div.telephone").first.inner_html ).gsub("TEL:", '') ) ; rescue ; nil
      end

      def website
        page.css(".visit-the-web").first.css("a:contains('website')").first.attribute("href").value ; rescue ; nil
      end

      def email
        page.css(".email.website").first.css("a").first.attribute('href').value.gsub("mailto:", '') ; rescue ; nil
      end

      def hours_note
        trim( page.css("dt:contains('Opening hours')").first.next_element.text ) ; rescue ; nil
      end

      def site_name
        "Travel + Leisure"
      end

      def category
        category = []
        if url.include?("/restaurants/")
          category.push "restaurant"
        elsif url.include?("/hotels/")
          category.push "hotel"
        elsif url.include?("/activities/")
          category.push "activity"
        end
        if metadata = page.css('.metadata')
          metadata.each do |metainstance|
            if types = metainstance.css('.type')
              types.each do |type|
                if !type.text.empty?
                  category.push trim(type.text)
                end
              end
            end
          end
        end
        return category
      end

      def price_note
        if price_area = page.css("li.cost").first
          if !price_area.css("img").empty?
            price_area.css("img").length
          end
        end
      end

      # def images
      #   image_list = []
      #   container = first_css_match(["#js-tab-photos", ".media-gallery__container"])
      #   container.css("img").each do |img_in_container|
      #     if img_in_container.attribute('src')
      #       unless img_in_container.attribute('src').value.include?("maps")
      #         img_url = img_in_container.attribute('src').value
      #       end
      #     end
      #     if img_url
      #       image_list.push( { url: img_url, source: @url, credit: site_name } )
      #     end
      #   end
      #   if image_list.length > 0 
      #     return image_list
      #   else
      #     return nil
      #   end
      # end

    end
  end
end