module Scrapers
  module HuffingtonpostMod

    # PAGE SETUP

    class Article < Huffingtonpost

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          plan:{
            name: page_title,
          },
          scraper_url: @url,
        }
      end

      # PAGE 

      def general_group
        group_array = []
        #find linked CAPITALIZED items NOT BOLD ANYMORE, JUNK

        if wrapper = page.css("#mainentrycontent")
          # if items = wrapper.inner_html.scan(%r!#{b_or_strong_open_thread}(.*?)#{b_or_strong_close_thread}!).flatten
          #   #clean notes, phone numbers & return array
          #   items.each do |item|
          #     unless item.match(%r!\ANote[:]?\Z!) || item.match(%r!\AStart[:]?\Z!) || item.match(%r!\AEssentials[:]?\Z!) || item.match(%r!\AGetting There[:]?\Z!) || item.match(%r!\AVisitor Information[:]?\Z!) || item.match(%r!\Atourist office[:]?\Z!) || item.match(%r!\AWhat to See!) || item.match(%r!\AWhere to Stay[:]?\Z!) || item.match(%r!\AWhere to Dine[:]?\Z!) || item.match(%r!#{phone_number_thread}!)
          #       group_array << [trim( de_tag( CGI.unescape( item ) ) ), nil]
          #     end
          #   end
          # end
          if items = wrapper.css("a")
            items.each do |item|
              unless item.attribute("href").value.match(%r!\A[#].*!) || item.text.include?("close") || item.text.include?("✖") || !item.text.match(/\A#{title_or_upper_case_word}.*/)
                link = item.attribute("href").value
                name = trim( item.text )
                group_array << [name, link]
              end
            end
          end
        end
        return group_array
      end

      def general_data(activity, activity_index)
        if activity[1]
          if activity[1].include?("huffingtonpost.com") || activity[1].include?("huffpo.com")
            more_info = activity[1]
          else 
            website = activity[1]
          end
        else
          website = nil
          more_info = nil
        end
        {
          place:{
            name: activity[0],
            nearby: nearby,
            website: website,
            more_info: more_info,
          },
        }
      end

      # OPERATIONS

      def page_title
        trim( CGI.unescape( breakline_to_space( page.css("title").first.text ) ) )
      rescue ; nil
      end

      def article_content
        page.css("#mainentrycontent").first
      rescue ; nil
      end

      def name(activity)
        trim( activity.scan(/(?:\d+\.)?(.*)/).flatten.first )
      rescue ; nil
      end

      def article_text
        if section_to_clean = page.css(".body").first.inner_html

        end
      rescue ; nil
      end

      def nearby        
        if page.css("h1.title").first
          if guess = guess_locale(page.css("h1.title").first.inner_html).values.compact.join(", ")
            return guess
          elsif page_title
            if guess = guess_locale(page_title).values.compact.join(", ")
              return guess
            elsif article_content
              if guess = guess_locale_rough(article_content.inner_html).values.compact.join(", ")
                return guess 
              end
            end
          end
        end
      rescue ; nil
      end

      def site_name
        "Huffington Post"
      end

    end
  end
end