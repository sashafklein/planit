module Scrapers
  module TripadvisorMod

    # PAGE SETUP

    class Guide < Tripadvisor

      def initialize(url, page)
        super(url, page)
        @scrape_target = ["#GUIDE_DETAIL"]
        @order_no = 0
      end

      def global_data
        { 
          scraper_url: @url, 
        }
      end

      # PAGE 
      
      def itinerary_data(itinerary, itinerary_index)
        {
          plan:{
            name: remove_plan_name_fluff( page.css("title").text ),
          },
        }
      end

      def day_group(leg)
        if scrape_content
          return [scrape_content] unless has_days?
          days = regex_split_without_loss_clean_before(scrape_content, day_within_hnum_regex)
        end
      end

      def day_data(day, day_index)
        if has_days?
          { 
            day:{
              order: day_index + 1,
            },
          }
        else
          {}
        end
      end

      def section_group(day)        
        [day]
      end
      
      def activity_group(section)
        activities = regex_split_without_loss_clean_before(section, guide_item_regex)
      end

      def activity_data(activity, activity_index)
        guide_no = activity.scan(find_guide_no_regex).flatten.first
        if guide_no
          @order_no += 1
          {
            place:{
              name: name(guide_no),
              lat: lat(guide_no),
              lon: lon(guide_no),
              price_note: price_info(guide_no),
              images: images(guide_no),
              ratings:{
                rating: rating(guide_no),
                site_name: site_name,
              },
            },
            item:{
              order: @order_no,
              duration_info: trim( duration_info(guide_no) ),
            },
          }
        else
          {}
        end
      end

      # OPERATIONS

      def has_days?
        return false unless scrape_content.scan(day_within_hnum_regex).length > 0
        true
      end

      def price_info(guide_no)
        if guide_no
          if cost = page.css("#guide_#{guide_no}").first.css("strong:contains('Cost:')").first
            if cost.next.text
              return trim( de_tag( cost.next.text ) )
            end
          end
          if fee = page.css("#guide_#{guide_no}").first.css("strong:contains('Fee:')").first
            if fee.next.text.include?("No")
              return "no fee"
            elsif fee.next.text.include?("Yes")
              return "has fee"
            else
              return trim( de_tag( fee.next.text ) )
            end
          end
        end
      end

      def site_name
        "Trip Advisor"
      end

      def lazy_load
        page.css("script:contains('lazyImgs')").first.inner_html ; rescue ; nil
      end

      def lazy_load_find_by_id(id, pre, post)
        lazy_load.scan(%r!#{pre}#{id}#{post}!).flatten.first; rescue ; nil
      end

      def images(guide_no)
        image_list = []
        if guide_no
          if img_in_container = page.css("#guide_#{guide_no}").first.css(".photo_image").first
            if img_in_container.attribute('src')
              img_url = img_in_container.attribute('src').value
            elsif img_in_container.attribute('id')          
              img_url = lazy_load_find_by_id(img_in_container.attribute('id').value, '\\"id\\":\\"', '\\".*?\\"data\\":\\"([^"]*)\\"')
            end
            if img_url
              image_list.push( { url: img_url, source: @url, credit: site_name } )
            end
          else
          end
        end
        return image_list
      end

      def map_hash
        if map_string = page.css("script:contains('MAP_MARKERS')").first.inner_html.split('MAP_MARKERS = ')[1].gsub(/\n/, " ")
          map_hash = eval( map_string )
        end
      end

      def lat(guide_no)
        if hash_item = map_hash.find{ |h| h[:locId]==guide_no.to_i }
          hash_item[:lat]
        end
      end

      def lon(guide_no)
        if hash_item = map_hash.find{ |h| h[:locId]==guide_no.to_i }
          hash_item[:lng]
        end
      end

      def rating(guide_no)
        calculate_rating( page.css("#guide_#{guide_no}").first.css('.sprite-ratings').first.attribute('alt').value, 5 )
      rescue ; nil
      end

      def duration_info(guide_no)
        page.css("#guide_#{guide_no}").first.css("strong:contains('Duration of visit:')").first.next.text ; rescue ; nil
      end

      def source_url(guide_no)
        page.css("#guide_#{guide_no}").first.css('.titleLink').first.attribute('href').value ; rescue ; nil
      end

      def name(guide_no)
        page.css("#guide_#{guide_no}").first.css('.titleLink').first.inner_html ; rescue ; nil
      end

    end
  end
end