module Scrapers
  module NytimesMod

    # PAGE SETUP

    class GeneralTravel < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main .articleBody #article article)
        @section_area = ""
      end

      def global_data
        { 
          plan:{
            name: remove_plan_name_fluff( page.css("title").text )
          },
          scraper_url: @url, 
        }
      end

      # PAGE 

      def general_group

        group_array = []
        @currently_in = ""

        wrapper.each do |wrap|
          if paragraphs = wrap.css("p")
            paragraphs.each do |paragraph|
              if text = trim( breakline_to_space( paragraph.inner_html ) )
                if title = text.scan( only_within_strong_strict_start_end ).flatten.first
                  title = trim( de_tag( title ) )
                  unless !title || title.empty?
                    if guessed_sublocale = guess_sublocale(title, guessed_locale)
                      @currently_in = guessed_sublocale
                    end
                  end
                elsif ( unflattened_activities = text.scan( capture_strong_phrase_accept_link_followed_by_parens ) ).length > 0
                  group_array.concat for_group_array( unflattened_activities.flatten )
                elsif ( unflattened_activities = text.scan( capture_strong_phrase_accept_link ) ).length > 0
                  group_array.concat for_group_array( unflattened_activities.flatten )
                elsif ( unflattened_activities = text.scan( capture_phrase_accept_link_followed_by_detail_parens ) ).length > 0
                  group_array.concat for_group_array( unflattened_activities.flatten )
                end
              end
            end
          end
        end
        return group_array
      end

      def general_data(activity, activity_index)
        {
          place:{
            name: name(activity),
            website: website(activity),
            phone: phone(activity),
            nearby: nearby(activity),
            extra: extra_address_or_note(activity),
            notes: notes_for( name(activity) )
          },
        }
      end

      # OPERATIONS

      def name(activity)
        trim( de_tag( activity.first ).split("(")[0] )
      end

      def website(activity)
        if website = activity.first.gsub(/\"/, '"').scan(%r!#{a_find_href_thread}!).flatten.first
          if website.include?("nytimes")
            website = nil
          end
          return website
        end
      end

      def phone(activity)
        phone = trim( de_tag( activity.first ) ).scan(%r!#{find_phone_number_between_comma_or_semicolon_or_parens}!).flatten.first
      end

      def nearby(activity)
        if guessed_locale.values.compact.present?
          return [trim(activity.last), guessed_locale[:region], guessed_locale[:country]].compact.join(", ") if activity.last.present?
          return guessed_locale.values.compact.join(", ")
        end
      end

      def extra_address_or_note(activity)
        trim( de_tag( activity.first).scan(/.*?\((.*?)(?:\)|\<|#{find_phone_number_between_comma_or_semicolon_or_parens}|[a-z]*?\.[a-z])/).flatten.first )
      end

      def guessed_locale
        return @guessed_locale if @guessed_locale.present?
        @guessed_locale = guess_locale([ page.css("title").text, page.css("h1").text, url ])
      end

      private

    end
  end
end

