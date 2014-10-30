module Scrapers  
  module Nyt
    class SeparatedDetails < Nytimes
      def initialize(url, page)
        super(url, page)
      end

    def get_detail_box_data
      if scrape_content
        set_days

        days.each_with_index do |day, day_number|
          day_number += 1
          day_times = day.scan(strong_index_title_and_time_on_own_line_regex_find_time).flatten
          day_sections = day.split(strong_index_title_and_time_on_own_line_regex).reject(&:blank?) # blank? returns false on '', so we're rejecting empty strings
          day_titles = day.scan(strong_index_title_and_time_on_own_line_regex_find_title).flatten || ''
          day_indices = day.scan(strong_index_title_and_time_on_own_line_regex_find_index).flatten || ''
          add_times_and_contents_to_section_array(day, day_number, day_times, day_sections, day_titles, day_indices)
        end

        # LEGEND
        if set_basics.present?
          lines = set_basics.scan(p_strong_details_regex) || []
          activities = []
          lines.each do |line|
            if line.match(p_strong_details_double_index_regex)
              line_number_1 = line.scan(p_strong_details_double_index_regex_find_first).flatten.first || ''
              line_activities_array = line.scan(strong_details_regex_find_activity).flatten || []
              for activity in line_activities_array
                activities << activity
              end
              line_number_2 = line.scan(p_strong_details_double_index_regex_find_second).flatten.first || ''
              for activity in line_activities_array
                activities << activity
              end
            else
              line_number = line.scan(p_strong_details_regex_find_index).flatten || ''
              line_activities_array = line.scan(strong_details_regex_find_activity).flatten || []
              for activity in line_activities_array
                activities << activity
              end
              binding.pry
            end
          end
          # add_activities_to_data_array(activities)
        end

      end
    end      
    end
  end
end