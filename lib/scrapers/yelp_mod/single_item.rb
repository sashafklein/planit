module Scrapers
  module YelpMod

    # PAGE SETUP

    class SingleItem < Yelp

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
            street_address: street_address,
            locality: locality,
            region: region,
            postal_code: postal_code,
            country: country,
            phone: phone,
            category: category,
            hours: hours,
            price_note: price_note,
            ratings:{
              rating: rating,
              site_name: site_name,
            },
            images: images,
            lat: lat,
            lon: lon,
          },
        }.merge(global_data)]
      end

      # JSON

      def map_json_bundle
        return @map_json_bundle unless !@map_json_bundle
        return @map_json_bundle = page.css('.lightbox-map').attr('data-map-state').value()
      end

      def map_json
        return @map_json unless !@map_json
        from_first_bracket = map_json_bundle
        to_parse = get_parseable_hash from_first_bracket
        return @map_json = JSON.parse( to_parse ).to_sh
      end

      # OPERATIONS

      def name
        [
          page.css("meta[property='og:title']").attr('content').value(),
          trim( de_tag( page.css('h1.biz-page-title').inner_html ) )
        ].compact.uniq.first
      rescue ; nil
      end

      def street_address
        page.css("span[itemprop='streetAddress']").inner_html ; rescue ; nil
      end

      def locality
        page.css("span[itemprop='addressLocality']").inner_html ; rescue ; nil
      end

      def region
        page.css("span[itemprop='addressRegion']").inner_html ; rescue ; nil
      end

      def postal_code
        page.css("span[itemprop='postalCode']").inner_html ; rescue ; nil
      end

      def country
        page.css("span[itemprop='countryName']").inner_html ; rescue ; nil
      end

      def phone
        trim( page.css("span.biz-phone").inner_html )
      rescue ; nil
      end

      def hours
        hours = {}
        if table = page.css('.hours-table')
          if rows = table.css("th")
            rows.each do |row|
              open_close = {}
              if row.next_element.css('span').length == 2
                open_close = {
                  start_time: row.next_element.css('span')[0].text,
                  end_time: row.next_element.css('span')[1].text,
                }
              elsif row.next_element.css("*:contains('Closed')")
                open_close = nil
              else
                open_close = nil
              end
              hours[row.text.to_sym] = open_close
            end
          end
        end
        return hours
      rescue ; nil
      end

      def site_name
        "Yelp"
      end

      def rating
        rate = ( page.css("i.star-img").attribute('title').value.split(" star")[0] ).to_i
        base = 5
        if rate
          return ( (rate * 100) / base ).round
        end
      rescue ; nil        
      end

      def price_note
        page.css("span[itemprop='priceRange']").first.inner_html ; rescue ; nil
      end

      def category
        category = []
        list = page.css("span.category-str-list").first.inner_html.split(",")
        list.each do |category_item|
          category.push trim ( de_tag ( category_item ) )
        end
        return category
      rescue ; nil
      end

      # def lazy_load
      #   page.css("script:contains('lazyImgs')").first.inner_html ; rescue ; nil
      # end

      # def lazy_load_find_by_id(id, pre, post)
      #   lazy_load.scan(%r!#{pre}#{id}#{post}!).flatten.first; rescue ; nil
      # end

      def images
        image_list = []
        container = first_css_match(["div.showcase-photos"])
        container.css("img").each do |img_in_container|
          if img_in_container.attribute('src')
            img_url = img_in_container.attribute('src').value
          # elsif img_in_container.attribute('id')          
          #   img_url = lazy_load_find_by_id(img_in_container.attribute('id').value, '\\"id\\":\\"', '\\".*?\\"data\\":\\"([^"]*)\\"')
          end
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end
        return image_list
      end

      def map_string
        container = first_css_match(["div.mapbox-map"])
        to_escape = container.css("img").first.attribute("src").value.split("center=")[1].split("&")[0]
        return CGI::unescape( to_escape )
      rescue ; nil
      end

      def lat
        [
          map_json.markers.starred_business.location.latitude,
          map_string.split(",")[0].try( :to_f ),
          map_json.center.latitude
        ].compact.uniq.first
      rescue ; nil
      end

      def lon
        [
          map_json.markers.starred_business.location.longitude,
          map_string.split(",")[1].try( :to_f ),
          map_json.center.longitude
        ].compact.uniq.first
      rescue ; nil
      end

    end
  end
end