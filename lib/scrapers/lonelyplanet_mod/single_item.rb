module Scrapers
  module LonelyplanetMod

    # PAGE SETUP

    class SingleItem < Lonelyplanet

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          site_name: site_name,
          source_url: @url,
        }
      end

      # PAGE 
      
      def data
        [{
          name: trim( name ),
          street_address: street_address,
          locality: locality,
          region: region,
          country: country,
          phone: phone,
          website: website,
          category: category,
          ranking: ranking,
          hours: hours,
          images: images,
          price_note: price_note,
          lat: lat,
          lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        trim( page.css("h1.copy--h1").first.text ) ; rescue ; nil
      end

      def street_and_zone
        trim( page.css("dt:contains('Address')").first.next_element.text ) ; rescue ; nil
      end

      def city_and_country
        trim( page.css("dt:contains('Location')").first.next_element.text ) ; rescue ; nil
      end

      def street_address
        street_and_zone
      end

      def phone
        trim( page.css("dt:contains('Telephone')").first.next_element.text ) ; rescue ; nil
      end

      def website
        page.css("dt:contains('More information')").first.next.css('a').first.attribute('href').value ; rescue ; nil
      end

      def hours
        trim( page.css("dt:contains('Opening hours')").first.next_element.text ) ; rescue ; nil
      end

      def locality
        if city_and_country.include?(country)
          return remove_punc( trim( city_and_country.gsub(country, '') ) )
        end
      end

      def country
        find_country(city_and_country)
      end

      def region
        find_region(city_and_country, country) ; rescue ; nil
      end

      def site_name
        "Lonely Planet"
      end

      def category
        category = []
        cat_string = page.css("div.card--page__breadcrumb").first.text
        if cat_string.include?("/")
          cat_list = cat_string.split("/")
          cat_list.each do |c|
            c = trim(c)
            if c.downcase == "restaurants"
              category.push "restaurant"
            elsif c.downcase == "sights"
              category.push "sight"
            elsif c.downcase == "activities"
              category.push "activity"
            elsif c.downcase != "other"
              category.push trim(c)
            end
          end
        else
          category.push trim( cat_string )
        end
        return category
      end

      def price_note
        trim( page.css("dt:contains('Prices')").first.next_element.text ) ; rescue ; nil
      end

      def ranking
        if page.css("div.card--top-choice").length > 0
          return "Top Choice"
        end
      end

      def lat
        page.css('.poi-map__container').attribute("data-latitude").value ; rescue ; nil
      end

      def lon
        page.css('.poi-map__container').attribute("data-longitude").value ; rescue ; nil
      end

      def images
        image_list = []
        container = first_css_match(["#js-tab-photos", ".media-gallery__container"])
        container.css("img").each do |img_in_container|
          if img_in_container.attribute('src')
            unless img_in_container.attribute('src').value.include?("maps")
              img_url = img_in_container.attribute('src').value
            end
          end
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end
        if image_list.length > 0 
          return image_list
        else
          return nil
        end
      end

    end
  end
end