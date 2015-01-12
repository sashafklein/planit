module Scrapers
  module NytimesMod

    # PAGE SETUP

    class GoogleThirtySixMapped < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def global_data
        { 
          plan:{
            name: remove_plan_name_fluff( page.css("title").text ),
          },
          place:{
            nearby: split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]]),
          },
          scraper_url: @url, 
        }
      end

      # PAGE 

      def activity_group_array
        return @activity_group_array if @activity_group_array
        array_in_activity_group_array = []
        if has_map_data?
          map_hash = JSON.parse(@map_data,:symbolize_names => true)
          map_hash[:symbols].each do |symbol|
            data = symbol[:data]
            array_in_activity_group_array << {
              name: breakline_to_space( name_in_data_hash(data) ),
              website: website_in_data_hash(data),
              lat: lat_in_data_hash(data),
              lon: lon_in_data_hash(data),
              street_address: address_in_data_hash(data),
              phone: phone_in_data_hash(data),
              order: order_in_data_hash(data),
            }
          end
          return @activity_group_array = array_in_activity_group_array
        end        
      end        

      def day_group(leg)
        if scrape_content
          return [scrape_content] unless has_days?
          days = [ scrape_content.scan(day_section_start_regex("friday")).flatten.first.split(day_section_cut_regex("saturday"))[0] ]
          days << scrape_content.scan(day_section_start_regex("saturday")).flatten.first.split(day_section_cut_regex("sunday"))[0]
          if has_legend?
            days << scrape_content.scan(day_section_start_regex("sunday")).flatten.first.split(day_section_cut_regex(["the basics", "the details", "if you go", "lodging"]))[0]
          else
            days << scrape_content.scan(day_section_start_regex("sunday")).flatten.first
          end
        end
      end

      def day_data(day, day_index)
        { 
          day:{
            order: day_index + 1,
          },
          item:{
            day_of_week: trim( day.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
          },
        }
      end

      def section_group(day)
        day_to_split = day.split(day_section_cut_regex_find_section)[1]
        sections = regex_split_without_loss(day_to_split, strong_index_title_and_time_then_linebreak_regex)
      end

      def section_data(section, section_index)
        { 
          item:{
            order: trim( section.scan(strong_index_title_and_time_then_linebreak_regex_find_index).flatten.first ).to_i,
            start_time: section.scan(strong_index_title_and_time_then_linebreak_regex_find_time).flatten.first,
          # content: trim( de_tag ( section.split(strong_index_title_and_time_then_linebreak_regex)[1] ) ),
          },
          place:{
            section_title: trim( section.scan(strong_index_title_and_time_then_linebreak_regex_find_title).flatten.first ),
          },
        }
      end
      
      def activity_group(section)
        section_relevant_index = section.scan(strong_index_title_and_time_then_linebreak_regex_find_index).flatten.first
        if has_map_data?
          group_to_sequence = activity_group_array.select{ |h| h[:order]==nil }
          group_to_sequence.each do |to_sequence|
            unless !to_sequence[:name]
              if section.scan(to_sequence[:name]).length > 0
                activity_group_array.find{ |h| h[:name]==to_sequence[:name] }[:order] = section_relevant_index
              end
            end
          end
          return activity_group_array.select{ |h| h[:order]==section_relevant_index }
        end
        return []
      end

      def activity_data(activity, activity_index)
        if has_map_data?
          {
            place:{
              name: trim( activity[:name] ),
              street_address: activity[:street_address],
              phone: activity[:phone], 
              lat: activity[:lat],
              lon: activity[:lon],
              website: activity[:website], 
            },
          }
        end
      end

      def general_group
        if has_map_data?
          return activity_group_array.select{ |h| h[:order]==nil }
        end
        return []
      end

      def general_data(activity, activity_index)
        if has_map_data?
          {
            place:{
              name: trim( activity[:name] ),
              street_address: activity[:street_address],
              phone: activity[:phone], 
              lat: activity[:lat],
              lon: activity[:lon],
              website: activity[:website], 
            },
          }
        end
      end

      # OPERATIONS

      def find_by_attr(hash, name_search, att=:name)
        hash.find{ |h| h[att] == name_search }
      end

      # NEEDS TO BE MORE STRINGENT
      def has_days?
        downcased = scrape_content.downcase
        return false unless %w(Friday Saturday Sunday).all?{ |weekend_day| downcased.include?(weekend_day.downcase) }
        true
      end

      # NEEDS TO BE MORE STRINGENT
      def has_legend?
        downcased = scrape_content.downcase
        return false unless (["the basics", "the details", "if you go", "lodging"]).any?{ |legend_group| downcased.include?(legend_group) }
        true
      end

      def has_map_data?
        for script in find_scripts_inner_html(page)
          if script.flatten.first.scan(nytimes_map_data_regex).length > 0
            @map_data = script.flatten.first.scan(nytimes_map_data_regex).flatten.first
            return true
          end
        end
        return false
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

