module Scrapers
  module FrommersMod

    # PAGE SETUP

    class Other < Frommers

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          plan:{
            name: page_title,
          },
          # site_name: site_name,
          # source_url: @url,
        }
      end

      # PAGE 

      def general_group
        group_array = []
        return [] unless is_acceptable?
        #find bolded items
        if wrapper = page.css(".body")
          if items = wrapper.inner_html.scan(%r!#{b_or_strong_open_thread}(.*?)#{b_or_strong_close_thread}!).flatten
            #clean notes, phone numbers & return array
            items.each do |item|
              unless item.match(%r!\ANote[:]?\Z!) || item.match(%r!\AStart[:]?\Z!) || item.match(%r!\AEssentials[:]?\Z!) || item.match(%r!\AGetting There[:]?\Z!) || item.match(%r!\AVisitor Information[:]?\Z!) || item.match(%r!\Atourist office[:]?\Z!) || item.match(%r!\AWhat to See!) || item.match(%r!\AWhere to Stay[:]?\Z!) || item.match(%r!\AWhere to Dine[:]?\Z!) || item.match(%r!#{phone_number_thread}!)
                group_array << trim( de_tag( CGI.unescape( item ) ) )
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
            nearby: nearby,
            category: category,
          },
          item:{
            order: order(activity),
          },
        }
      end

      # OPERATIONS

      def page_title
        trim( CGI.unescape( breakline_to_space( page.css("title").first.text ) ) )
      rescue ; nil
      end

      def is_acceptable?
        if page.css(".left-sidebar").css("h3").first.text && page.css(".body").first.text
          return true
        end
        return false
      rescue ; nil
      end

      def name(activity)
        trim( activity.scan(/(?:\d+\.)?(.*)/).flatten.first )
      rescue ; nil
      end

      def order(activity)
        order = activity.scan(/(?:(\d+)\.)?.*/).flatten.first
        return nil unless order.to_i > 0
        return order.to_i
      rescue ; nil
      end

      def article_text
        if section_to_clean = page.css(".body").first.inner_html

        end
      rescue ; nil
      end

      def breadcrumb
        breadcrumb = de_tag(page.css(".breadcrumbs").first.inner_html.gsub("❭", ' '))
      rescue ; nil
      end

      def nearby        
        if !breadcrumb.include?("Side Trips")
          return guess_locale([breadcrumb])[3]
        elsif breadcrumb.include?("Side Trips")
          sub_locale = trim( breadcrumb.split("Side Trips")[1].split("&")[0] )
          if sub_locale.blank?
            return guess_locale([breadcrumb])[3]
          else
            return [sub_locale, guess_locale([breadcrumb])[1], guess_locale([breadcrumb])[2]].reject(&:blank?).compact.join(", ")
          end
        end
      rescue ; nil
      end

      def site_name
        "Frommers"
      end

      def category
        category = []
        if breadcrumb.downcase.include?('restaurants')
          category.push "restaurant"
        elsif breadcrumb.downcase.include?("attractions")
          category.push "attraction"
        elsif breadcrumb.downcase.include?("hotels")
          category.push "hotel"
        elsif breadcrumb.downcase.include?("shopping")
          category.push "shopping"
        elsif breadcrumb.downcase.include?("nightlife")
          category.push "nightlife"
        end
        return category
      rescue ; nil
      end

    end
  end
end