module Scrapers
  module FrommersMod

    # PAGE SETUP

    class CleanList < Frommers

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url,
        }
      end

      # PAGE 
      
      def general_group
        group_array = []
        if sortable_table = page.css(".table.sortable").first
          if rows = sortable_table.css("tbody").first.css("tr")
            rows.each do |row|
              group_array << row
            end
          end
        end
        return group_array
      end

      def general_data(activity, activity_index)
        {
          place:{
            name: name(activity),
            more_info: more_info(activity),
            neighborhood: neighborhood(activity),
            price_note: price_note(activity),
            nearby: nearby,
            ratings:{
              ranking: ranking(activity),
              site_name: site_name,
            },
          },
        }
      end

      # OPERATIONS

      def name(row)
        trim( row.css("td")[2].text )
      rescue ; nil
      end

      def more_info(row)
        if link = row.css("td")[2].css("a").first.attribute("href").value
          return "http://www.frommers.com#{link}"
        end
      rescue ; nil
      end

      def neighborhood(row)
        trim( row.css("td")[4].text )
      rescue ; nil
      end

      def nearby
        breadcrumb = de_tag(page.css(".breadcrumbs").first.inner_html.gsub("❭", ' '))
        if !breadcrumb.include?("Side Trips")
          return guess_locale([breadcrumb])[3]
        elsif breadcrumb.include?("Side Trips")
          sub_locale = trim( breadcrumb.split("Side Trips")[1].split("&")[0] ) 
          return [sub_locale, guess_locale([breadcrumb])[1], guess_locale([breadcrumb])[2]].join(", ")
        end
      rescue ; nil
      end

      def site_name
        "Frommers"
      end

      def category
        category = []
        if url.include?('/restaurants')
          category.push "restaurant"
        elsif url.include?("/attractions")
          category.push "attraction"
        elsif url.include?("/hotels")
          category.push "hotel"
        elsif url.include?("/shopping")
          category.push "shopping"
        elsif url.include?("/nightlife")
          category.push "nightlife"
        end
        if row.css("td")[3].text
          category.push trim( row.css("td")[3].text )
        end
        return category
      rescue ; nil
      end

      def price_note(row)
        if dollar = row.inner_html.scan(/icon_dollar(\d)\./).flatten.first.to_i
          if dollar == 0
            return "cheap"
          end
          return ("$" * dollar)
        end
      rescue ; nil
      end

      def ranking(row)
        if star = row.inner_html.scan(/star_meter(\d)\./).flatten.first.to_i
          if star == 1
            return "#{star} star"
          elsif star > 1
            return "#{star} stars"
          end
        end
      rescue ; nil
      end

    end
  end
end