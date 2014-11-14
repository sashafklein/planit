module Scrapers
  module NytimesMod

    # PAGE SETUP

    class GeneralTravel < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
        @section_area = ""
      end

      def global_data
        { 
          plan:{
            name: page.css("title").text
          },
        }
      end

      # PAGE 

      def general_group
        group_array = []
        @currently_in = ""

        # binding.pry
        # @scrape_target.each do |try_wrapper|
        #   binding.pry
        #   if page.css(try_wrapper).first
        #     binding.pry
        #     wrapper = page.css(try_wrapper).first
        #   end
        # end
        # if wrapper

        if wrapper = page.css(".articleBody")
          if paragraphs = wrapper.css("p[itemprop='articleBody']")
            paragraphs.each do |paragraph|
              if text = trim( breakline_to_space( paragraph.inner_html ) )
                if title = text.scan( only_within_strong_strict_start_end ).flatten.first
                  title = trim( de_tag( title ) )
                  unless !title || title.empty?
                    if guessed_sublocale = guess_sublocale(title, guessed_locale)
                      @currently_in = guessed_sublocale
                    end
                  end
                elsif text.scan( capture_strong_phrase_accept_link_followed_by_parens ).length > 0
                  activities = text.scan( capture_strong_phrase_accept_link_followed_by_parens ).flatten
                  activities.each do |activity|
                    unless !trim( de_tag( activity ) ) || trim( de_tag( activity ) ).empty?
                      group_array << [activity, @currently_in]
                    end
                  end
                elsif text.scan( capture_strong_phrase_accept_link ).length > 0
                  activities = text.scan( capture_strong_phrase_accept_link ).flatten
                  activities.each do |activity|
                    unless !trim( de_tag( activity ) ) || trim( de_tag( activity ) ).empty?
                      group_array << [activity, @currently_in]
                    end
                  end
                elsif text.scan( capture_phrase_accept_link_followed_by_detail_parens ).length > 0
                  activities = text.scan( capture_phrase_accept_link_followed_by_detail_parens ).flatten
                  activities.each do |activity|
                    unless !trim( de_tag( activity ) ) || trim( de_tag( activity ) ).empty?
                      group_array << [activity, @currently_in]
                    end
                  end
                end
              end
            end
          end
        end
        return group_array
      end

      def general_data(activity, activity_index)
        name = trim( de_tag( activity.first ).split("(")[0] )
        if website = activity.first.gsub(/\"/, '"').scan(%r!#{a_find_href_thread}!).flatten.first
          if website.include?("nytimes")
            website = nil
          end
        end
        phone = trim( de_tag( activity.first ) ).scan(%r!#{find_phone_number_between_comma_or_semicolon_or_parens}!).flatten.first
        if activity.last.present?
          nearby = [trim(activity.last), @guessed_locale[1], @guessed_locale[2]].compact.join(", ")
        else
          nearby = @guessed_locale[3]
        end
        extra_address_or_note = trim( de_tag( activity.first).scan(/.*?\((.*?)(?:\)|\<|#{find_phone_number_between_comma_or_semicolon_or_parens}|[a-z]*?\.[a-z])/).flatten.first )
        {
          place:{
            name: name,
            website: website,
            phone: phone,
            nearby: nearby,
            extra: extra_address_or_note,
          },
        }
      end

      # OPERATIONS

      def guessed_locale
        @guessed_locale = guess_locale([ page.css("title").text, page.css("h1").text, url ]) #returns locality, region, country, full_string
      end

    end
  end
end

