module Scrapers
  module NytimesMod

    # PAGE SETUP

    class RestaurantReview < Nytimes
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(.story-info)
      end

      def global_data
        { 
          place:{
            nearby: find_nearby, #default but overrideable
          }
        }
      end

      # PAGE 

      def activity_group(section)
        if has_story_info?
          
        else
          return []
        end
      end

      def activity_data(activity, activity_index)
        if has_story_info?
          {
            place:{
              name: activity[:name],
              street_address: activity[:street_address],
              phone: activity[:phone], 
              lat: activity[:lat],
              lon: activity[:lon],
              website: activity[:website], 
            }
          }
        end
      end

      # OPERATIONS

      def has_story_info?
        if ___
          return true
        end
        return false
      end

      def find_nearby
        "New York City, New York, United States"
      end

      def name_in_data_hash(data)
        find_by_attr(data, 'label')[:text] ; rescue ; nil
      end

      def website_in_data_hash(data)
        find_by_attr(data, 'popup')[:body].scan(find_website_after_n).flatten.first ; rescue ; nil
      end

      def lat_in_data_hash(data)
        find_by_attr(data, 'root')[:location][:lat] ; rescue ; nil
      end

      def lon_in_data_hash(data)
        find_by_attr(data, 'root')[:location][:lng] ; rescue ; nil
      end

      def phone_in_data_hash(data)
        find_by_attr(data, 'popup')[:body].scan(find_phone_after_n).flatten.first ; rescue ; nil
      end

      def order_in_data_hash(data)
        find_by_attr(data, 'bubble_number')[:text] ; rescue ; nil
      end

      def address_in_data_hash(data)
        find_by_attr(data, 'popup')[:body].scan(find_address_after_n).flatten.first ; rescue ; nil
      end

    end
  end
end

