module Scrapers
  module LonelyplanetMod

    # PAGE SETUP

    class SingleItem < Lonelyplanet

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
            name: trim( name ),
            full_address: full_address,
            phone: phone,
            website: website,
            category: category,
            ratings:{
              ranking: ranking,
              site_name: site_name,
            },
            hours_note: hours_note,
            images: images,
            price_note: price_note,
            lat: lat,
            lon: lon,
          },
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

      def full_address
        if street_and_zone || city_and_country
          return [street_and_zone, city_and_country].compact.join(", ")
        end
      end

      def phone
        trim( page.css("dt:contains('Telephone')").first.next_element.text ) ; rescue ; nil
      end

      def website
        page.css("dt:contains('More information')").first.next.css('a').first.attribute('href').value ; rescue ; nil
      end

      def hours_note
        trim( page.css("dt:contains('Opening hours')").first.next_element.text ) ; rescue ; nil
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