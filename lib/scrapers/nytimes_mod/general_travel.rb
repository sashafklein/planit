module Scrapers
  module NytimesMod

    # PAGE SETUP

    class GeneralTravel < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
        @section_area = ""
      end

      def guessed_locale
        @guessed_locale = guess_locale([ page.css("title").text, page.css("h1").text, url ]) #returns locality, region, country, full_string
      end

      def global_data
        { 
          place:{
            nearby: guessed_locale[3], #returns locality, region, country, full_string
          },
          plan:{
            name: page.css("title").text
          },
        }
      end

      # PAGE 

      # def activity_group_array
      #   return @activity_group_array if @activity_group_array
      #   array_in_activity_group_array = []
      #   if has_legend?
      #     activity_details_container = scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go"])).flatten.first
      #     return @activity_array_group = activity_details_container.scan(p_strong_details_regex)
      #   elsif has_map_data?
      #     map_hash = JSON.parse(@map_data,:symbolize_names => true)
      #     map_hash[:symbols].each do |symbol|
      #       data = symbol[:data]
      #       array_in_activity_group_array << {
      #         name: breakline_to_space( name_in_data_hash(data) ),
      #         website: website_in_data_hash(data),
      #         lat: lat_in_data_hash(data),
      #         lon: lon_in_data_hash(data),
      #         street_address: address_in_data_hash(data),
      #         phone: phone_in_data_hash(data),
      #         order: order_in_data_hash(data),
      #       }
      #     end
      #     return @activity_group_array = array_in_activity_group_array
      #   end        
      # end        

      # def day_group(leg)
      #   if scrape_content
      #     return [scrape_content] unless has_days?
      #     days = [ scrape_content.scan(day_section_start_regex("friday")).flatten.first.split(day_section_cut_regex("saturday"))[0] ]
      #     days << scrape_content.scan(day_section_start_regex("saturday")).flatten.first.split(day_section_cut_regex("sunday"))[0]
      #     if has_legend?
      #       days << scrape_content.scan(day_section_start_regex("sunday")).flatten.first.split(day_section_cut_regex(["the basics", "the details", "if you go"]))[0]
      #     else
      #       days << scrape_content.scan(day_section_start_regex("sunday")).flatten.first
      #     end
      #   end
      # end

      # def day_data(day, day_index)
      #   { 
      #     day_number: day_index + 1,
      #     day_title: trim( day.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
      #   }
      # end

      # def section_group(day)
      #   day_to_split = day.split(day_section_cut_regex_find_section)[1]
      #   sections = regex_split_without_loss(day_to_split, strong_index_title_and_time_then_linebreak_regex)
      # end

      # def section_data(section, section_index)
      #   { 
      #     order: section.scan(strong_index_title_and_time_then_linebreak_regex_find_index).flatten.first,
      #     time: section.scan(strong_index_title_and_time_then_linebreak_regex_find_time).flatten.first,
      #     section_title: trim( section.scan(strong_index_title_and_time_then_linebreak_regex_find_title).flatten.first ),
      #     content: trim( de_tag ( section.split(strong_index_title_and_time_then_linebreak_regex)[1] ) ),
      #   }
      # end
      
      # def activity_group(section)
      #   section_relevant_index = section.scan(strong_index_title_and_time_then_linebreak_regex_find_index).flatten.first
      #   if !has_map_data?
      #     for group_to_test in activity_group_array
      #       group_index = group_to_test.scan(p_strong_details_regex_find_index).flatten.first
      #       if group_index == section_relevant_index
      #         return group_to_test.scan(strong_details_regex_find_activity).flatten
      #       end
      #     end
      #   else
      #     group_to_sequence = activity_group_array.select{ |h| h[:order]==nil }
      #     group_to_sequence.each do |to_sequence|
      #       unless !to_sequence[:name]
      #         if section.scan(to_sequence[:name]).length > 0
      #           activity_group_array.find{ |h| h[:name]==to_sequence[:name] }[:order] = section_relevant_index
      #         end
      #       end
      #     end
      #     return activity_group_array.select{ |h| h[:order]==section_relevant_index }
      #   end
      #   return []
      # end

      # def activity_data(activity, activity_index)
      #   if has_map_data?
      #     {
      #       name: activity[:name],
      #       street_address: activity[:street_address],
      #       phone: activity[:phone], 
      #       lat: activity[:lat],
      #       lon: activity[:lon],
      #       website: activity[:website], 
      #     }
      #   else
      #     {
      #       name: trim( de_tag( activity.scan(strong_details_regex_find_name).flatten.first ) ),
      #       street_address: trim( activity.scan(strong_details_regex_find_address_phone).flatten.first ),
      #       website: activity.scan(a_regex_find_href).flatten.first,
      #     }
      #   end
      # end

      # strong w/ or w/o link (in any portion)
      # parenthetical in more info
      # not just links
      # try to place within nearby via title above?  changes as you move through titles -- title is upcase

      def general_group
        if legend?
          group_array = []
          legend_item = legend?.parent
          while legend_item.next_element
            group_array << legend_item.next_element
            legend_item = legend_item.next_element
          end
          binding.pry
          return group_array
        end
        if has_map_data?
          return activity_group_array.select{ |h| h[:order]==nil }
        end
        return []
      end

      def general_data(activity, activity_index)
        if has_map_data?
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
        if legend?
          if activity.inner_html.include?("(") && activity.inner_html.include?(")") 
            content = activity
            binding.pry
            name = content.css("strong").text
          elsif @guessed_locale && @guessed_locale.length == 4
            if @section_area = guess_sublocale( activity.inner_html, @guessed_locale )
              binding.pry 
              # next
            end
          end
          return {}
          # test if content or title
          # if title, check for geography
          #   if 
          # {
          #   name: activity[:name],
          #   street_address: activity[:street_address],
          #   phone: activity[:phone], 
          #   lat: activity[:lat],
          #   lon: activity[:lon],
          #   website: activity[:website], 
          # }
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

      def legend?
        ["if you go", "the details", "the basics"].each do |term|
          ["downcase", "titleize", "upcase", "capitalize"].each do |operator|
            search_term = term.send(operator)
            if separation = page.css("strong:contains('#{search_term}')").first
              return separation
            end
          end
        end
        return false
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

