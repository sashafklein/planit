module Scrapers
  module TripadvisorMod

    # PAGE SETUP

    class UserReviews < Tripadvisor

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
            name: trim( de_tag( name ) ),
            street_addresses: street_addresses,
            extended_address: extended_address,
            locality: locality,
            region: region,
            postal_code: postal_code,
            country: country,
            phone: trim( phone ),
            category: category,
            price_note: trim( price_info ),
            ratings:{
              site_name: site_name,
              rating: rating,
              ranking: trim( de_tag ( ranking ) ),
            },
            images: images,
            lat: lat,
            lon: lon,
          },
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css('.HEADING').inner_html ; rescue ; nil
      end

      def street_addresses
        page.css("span[property='v:street-address']").map(&:inner_html).compact.uniq ; rescue ; nil
      end

      def extended_address
        page.css("span.extended-address").first.inner_html ; rescue ; nil
      end

      def locality
        page.css("span[property='v:locality']").inner_html ; rescue ; nil
      end

      def region
        page.css("span[property='v:region']").inner_html ; rescue ; nil
      end

      def postal_code
        page.css("span[property='v:postal-code']").first.inner_html ; rescue ; nil
      end

      def country
        page.css("span[property='v:country-name']").inner_html ; rescue ; nil
      end

      def phone
        page.css('.phoneNumber').inner_html ; rescue ; nil
      end

      def site_name
        "Trip Advisor"
      end

      def ranking
        page.css('b.rank_text').inner_html ; rescue ; nil
      end

      def rating
        calculate_rating( page.css('.metacontent').css('img.rating_no_fill').first.attribute('alt').value, 5 )
      rescue ; nil        
      end

      def price_info
        page.css("b:contains('Price range:')").first.next.text ; rescue ; nil
      end

      def category
        page.css(".slim_ranking").first.css("a").inner_html.split("s in")[0] ; rescue ; nil
      end

      def lazy_load
        page.css("script:contains('lazyImgs')").first.inner_html ; rescue ; nil
      end

      def lazy_load_find_by_id(id, pre, post)
        lazy_load.scan(%r!#{pre}#{id}#{post}!).flatten.first; rescue ; nil
      end

      def images
        image_list = []
        container = first_css_match([".ug_thumbs", "div.sizedThumb_container", "div.photo_slideshow", "div.photoGrid.photoBx"])
        container.css("img").each do |img_in_container|
          if img_in_container.attribute('src')
            img_url = img_in_container.attribute('src').value
          elsif img_in_container.attribute('id')          
            img_url = lazy_load_find_by_id(img_in_container.attribute('id').value, '\\"id\\":\\"', '\\".*?\\"data\\":\\"([^"]*)\\"')
          end
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end
        return image_list
      end

      def map_string
        container = first_css_match([".STATIC_MAP", "#STATIC_MAP"])
        lazy_load_find_by_id(container.css("img").first.attribute("id").value, '\\"id\\":\\"', '\\".*?\\"data\\":\\"([^"]*)\\"')
      end

      def lat
        map_string.split("center=")[1].split("&")[0].split(",")[0] ; rescue ; nil
      end

      def lon
        map_string.split("center=")[1].split("&")[0].split(",")[1] ; rescue ; nil
      end

    end
  end
end