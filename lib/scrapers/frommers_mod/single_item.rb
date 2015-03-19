module Scrapers
  module FrommersMod

    # PAGE SETUP

    class SingleItem < Frommers

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url,
        }
      end

      # PAGE 
      
      def data
        [{
          place:{
            name: name,
            nearby: nearby,
            neighborhood: neighborhood,
            hours_note: hours_note,
            phone: phone,
            price_note: price_note,
            website: website,
            category: category,
            extra: extra_address_or_note,
            ratings:{
              ranking: ranking,
              site_name: site_name,
            },
          },
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        trim( page.css("h1").first.try( :text ) ) 
      end

      def extra_address_or_note
        trim( page.css("h1").first.try( :next_element ).try( :text ) )
      end

      def property_table
        page.css(".table-properties").first
      end

      def neighborhood
        result = property_table.css("th:contains('Neighborhood')").first.try( :next_element ).try( :text )
        trim( de_tag( CGI.unescape( result ) ) ) if result
      end

      def hours_note
        result = property_table.css("th:contains('Hours')").first.try( :next_element ).try( :text )
        trim( de_tag( CGI.unescape( result ) ) ) if result
      end

      def phone
        result = property_table.css("th:contains('Phone')").first.try( :next_element ).try( :text )
        trim( de_tag( CGI.unescape( result ) ) ) if result
      end

      def price_note
        result = property_table.css("th:contains('Prices')").first.try( :next_element ).try( :text )
        trim( de_tag( CGI.unescape( result ) ) ) if result
      end

      def website
        if guess = property_table.css("th:contains('Website')").first
          return guess.next_element.css("a").first.attribute("href").value
        elsif guess = property_table.css("th:contains('Web site')").first
          return guess.next_element.css("a").first.attribute("href").value 
        end
      end

      def nearby
        guess_locale([de_tag(page.css(".breadcrumbs").first.inner_html.gsub("❭", ' '))]).values.compact.join(", ")
      end

      def site_name
        "Frommers"
      end

      def category
        category = []
        if url.include?('/restaurants/')
          category.push "restaurant"
        elsif url.include?("/attractions/")
          category.push "attraction"
        elsif url.include?("/hotels/")
          category.push "hotel"
        elsif url.include?("/shopping/")
          category.push "shopping"
        elsif url.include?("/nightlife/")
          category.push "nightlife"
        end
        if another = property_table.css("th:contains('Cuisine Type')").first
          category << trim( de_tag( CGI.unescape( property_table.css("th:contains('Cuisine Type')").first.try( :next_element ).try( :text ) ) ) )
        end
        return category
      end

      def ranking
        if star = page.css("h1").first.css("img").first.attribute("src").value.scan(/star_meter(\d)\./).flatten.first.to_i
          if star == 1
            return "#{star} star"
          elsif star > 1
            return "#{star} stars"
          end
        end
      end

    end
  end
end