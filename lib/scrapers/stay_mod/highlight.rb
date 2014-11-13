module Scrapers
  module StayMod

    # PAGE SETUP

    class Highlight < Stay

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          # site_name: site_name,
          # source_url: @url,
          plan:{
            name: page.css("title").text,
          },
        }
      end

      # PAGE 
      
      def activity_group(section)
        tab_content.css(".partial-item-box")
      rescue ; nil
      end

      def activity_data(activity, index)
        {
          place:{
            name: name(activity),
            ratings:{
              rating: rating(activity),
              site_name: site_name,
            },
            category: category(activity),
            images: images(activity),
            lat: lat(activity),
            lon: lon(activity),
          },
        }
      end

      # OPERATIONS

      def tab_content
        page.css("#tab-content").first.css(".partial-item-box").each do |test_or_remove|
          if test_or_remove.attribute("class").value.include?("template")
            test_or_remove.remove
          end
        end
        page.css("#tab-content").first
      rescue ; nil
      end

      def script_content
        page.css("script:contains('#venue-map')").first
      rescue ; nil
      end

      def site_name
        "Stay"
      end

      # ACTIVITY-SPECIFIC OPERATIONS

      def name(activity)
        trim( activity.css("a.item-url").first.text )
      rescue ; nil
      end

      def rating(activity)
        rate = ( activity.css(".stay-rank").first.css("span").first.css("i").text ).to_i
        base = 5.0
        if rate
          return ( (rate * 100) / base ).round
        end
      rescue ; nil
      end

      def category(activity)
        category = []
        category.push trim( activity.css(".category").text )
      rescue ; nil
      end

      def images(activity)
        image_list = []
        img_url = activity.css("img").first.attribute("src").value
        if img_url
          image_list.push( { url: img_url, source: @url, credit: site_name } )
        end
        return image_list
      rescue ; nil
      end

      def lat(activity)
        id = activity.attribute("class").value.scan(/id(\d+)/).flatten.first
        script_content.inner_html.scan(find_lng_by_script_id(id)).flatten.first
      rescue ; nil
      end

      def lon(activity)
        id = activity.attribute("class").value.scan(/id(\d+)/).flatten.first
        script_content.inner_html.scan(find_lat_by_script_id(id)).flatten.first
      rescue ; nil
      end

    end
  end
end