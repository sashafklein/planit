module Scrapers
  module GeneralMod

    # PAGE SETUP

    class Catchall < General

      attr_accessor :locality, :region, :postal_code, :country, :street_address, :nearby
      def initialize(url, page)
        super(url, page)
      end

      # PAGE 

      def data
        # assumes single location per page, sorts for best possible results
        [ place: {
            lat: lat,
            lon: lon,
            name: name,
            nearby: nearby,
            full_address: full_address,
            street_address: street_address,
            locality: locality,
            region: region,
            postal_code: postal_code,
            country: country,
            phones: phone,
            hours: hours,
            map_href: map_href,
            # images: images,
          },
          scraper_url: @url,
        ]
      end

      # OPERATIONS

      # DOES IT HAVE MAP LINKS? PARSE LINKS, LINK TEXT

      def map_images
        page.css("img")
          .map{ |img| img.attribute('src').try(:value) }
          .compact
          .select{ |src| map_link_src_usual_suspects
            .any?{ |s| src.include?(s) }
          }
      end

      def map_links
        page.css("a")
          .map{ |link| link.attribute('href').try(:value) }
          .compact
          .select{ |href| map_link_src_usual_suspects
            .any?{ |s| href.include?(s) }
          }
      end

      # SOCIAL DATA SCRAPING

      def google
        return @google if @google
        if map_string && map_string.include?("google")
          map_string.each do |string|
            query = find_query_name_in_map_string(string)
            return @google = trim( query )
          end
        end
      end

      def twitter
        return @twitter if @twitter
        page.css("a").each do |link|
          if title = link.attribute("title")
            if title.value.match(/Follow .*? on Twitter/)
              title_match = title.value.scan(/Follow (.*?) on Twitter/).flatten.first
              return @twitter = title_match unless title_match && title_match.downcase == "us"
            end
          end
        end
        if meta = page.css("meta[name='twitter:title']").first
          if meta.attribute("content")
            return @twitter = meta.attribute("content").value
          end
        end
        return nil
      end

      def facebook
        return @facebook if @facebook
        page.css("a").each do |link|
          if title = link.attribute("title")
            if title.value.match(/Become a fan of .*? on Facebook/)
              @facebook_href = link.attribute("href").value
              title_match = title.value.scan(/Become a fan of (.*?) on Facebook/).flatten.first
              return @facebook = title_match unless !title_match || title_match.downcase == "us"
            end
          end
          if href = link.attribute("href")
            if href.value.match(/.*facebook.com\/pages.*/)
              @facebook_href = link.attribute("href").value
              href_match = href.value.scan(/pages\/.*?\//).flatten.first
              href_match = href_match.gsub("-", " ") || ''
              href_match = href_match.titleize
              return @facebook = href_match
            end
          end
          if text = link.text
            if text.include?("facebook")
              @facebook_href = link.attribute("href").value
              text_match = link.text.scan(/(?:Become a fan of |\A)(.*?) on Facebook/).flatten.first
              return @facebook = text_match unless !text_match || text_match.downcase == "us"
            end
          end
        end
        return nil
      end

      def yelp
      end

      def tripadvisor
      end

      # META DATA SCRAPING

      def title
        return @title if @title
        @title = trim( page.css("title").text ) 
      end

      def meta_description
        return @meta_description if @meta_description
        if meta_tag = page.css("meta[name='description']").first
          return @meta_description = meta_tag.attribute("content").value
        end
        return nil
      end

      def meta_keywords
        return @meta_keywords if @meta_keywords
        if meta_tag = page.css("meta[name='keywords']").first
          return @meta_keywords = meta_tag.attribute("content").value
        end
        return nil
      end

      def meta_name
        return @meta_name if @meta_name
        return @meta_name = get_usual_suspect_text(meta_name_usual_suspects)
        return nil
      end

      # ON PAGE DATA SCRAPING

      def heading
        return @heading if @heading
        return @heading = get_usual_suspect_text(heading_usual_suspects)
        return nil
      end

      def details_name
        return @details_name if @details_name
        return @details_name = get_usual_suspect_text(details_name_usual_suspects)
        return nil
      end

      def full_address
        return @full_address if @full_address
        full_address_from_map, full_address_from_box = nil
        if attempt_from_address_box = get_usual_suspect_text(full_address_usual_suspects)
          attempt_from_address_box = clean_address_box( attempt_from_address_box )
          attempt_from_address_box = attempt_from_address_box.gsub(/\A#{name}/, '') unless !attempt_from_address_box
          attempt_from_address_box = attempt_from_address_box.gsub(/\A#{name.gsub(%r!(?:#{cased(lowercase_destination_class).join("|")}\Z|#{cased(lowercase_destinations_plural_class).join("|")}\Z)!, '')}/, '') unless !attempt_from_address_box || !name
          attempt_from_address_box = trim( attempt_from_address_box )
          full_address_from_box = attempt_from_address_box
        end
        if map_string
          map_string.each do |string|
            query = find_query_address_in_map_string(string, name)
            full_address_from_map = query
          end
        end
        if full_address_from_box && full_address_from_map
          if full_address_from_map.downcase.include?(full_address_from_box.downcase)
            return @full_address = full_address_from_map
          elsif full_address_from_box.downcase.include?(full_address_from_map.downcase)
            return @full_address = full_address_from_box 
          elsif full_address_from_map.length > full_address_from_box.length
            return @full_address = full_address_from_map 
          else
            return @full_address = full_address_from_box
          end
        elsif full_address_from_box && !full_address_from_map
          return @full_address = full_address_from_box
        elsif full_address_from_map && !full_address_from_box
          return @full_address = full_address_from_map  
        end
        return nil
      end

      def street_address
        return @street_address if @street_address
        return @street_address = get_usual_suspect_text(street_address_usual_suspects)
        return nil
      end

      def country
        return @country if @country
        return @country = get_usual_suspect_text(country_usual_suspects)
        return nil
      end

      def region
        return @region if @region
        return @region = get_usual_suspect_text(region_usual_suspects)
        return nil
      end

      def postal_code
        return @postal_code if @postal_code
        return @postal_code = get_usual_suspect_text(postal_code_usual_suspects)
        return nil
      end

      def phone
        return @phone if @phone
        page.css("a").each do |link|
          if link.attribute("href")
            if link.attribute("href").value.include?("tel:")
              phone_number = link.attribute("href").value.gsub("tel:", '') || ''
              return @phone = phone_number unless phone_number.length < 6
            end
          end
        end
        return @phone = get_usual_suspect_text(phone_usual_suspects)
        return nil
      end

      def nearby
        return @nearby if @nearby
        unless lat && lon
          page_content_to_scan = [ meta_keywords, meta_description, title, page.text ]
          guesses = page_content_to_scan.map{ |content| guess_locale( content ) }
          @locality ||= top_pick( guesses.compact.map{ |g| g[:locality] } )[:is]
          @region ||= top_pick( guesses.compact.map{ |g| g[:region] } )[:is]
          @country ||= top_pick( guesses.compact.map{ |g| g[:country] } )[:is]
          @nearby = [@locality, @region, @country].compact.join(", ")
        end
      end

      def map_string
        return @map_string if @map_string
        return @map_string = (map_links + map_images).compact
      end

      def lat
        return @lat if @lat
        if map_string
          map_string.each do |string|
            string = string.gsub("%2C", ",") || ''
            latlon = string.scan( find_lat_lon_in_href ).flatten.first
            return @lat = latlon.split(",")[0] unless !latlon
          end
        end
        if lat_on_page = get_usual_suspect_text(latitude_usual_suspects)
          return @lat = lat_on_page
        end
        return nil
      end

      def lon
        return @lon if @lon
        if map_string
          map_string.each do |string|
            string = string.gsub("%2C", ",") || ''
            latlon = string.scan( find_lat_lon_in_href ).flatten.first
            return @lon = latlon.split(",")[1] unless !latlon
          end
        end
        if lon_on_page = get_usual_suspect_text(longitude_usual_suspects)
          return @lon = lon_on_page
        end
        return nil
      end

      def hours
        # %w(.hours #hours)
      end

      def trimmed_keyword
        if meta_keywords
          trimmed_keyword = meta_keywords.gsub(/\,.*/, '')
          return trimmed_keyword = before_divider( trimmed_keyword )
        end
        return nil
      end

      def trimmed_description
        if meta_description
          trimmed_description = meta_description
          trimmed_description = trimmed_description.gsub(/ is a .*/, '') || ''
          trimmed_description = trimmed_description.gsub(/ is the .*/, '') || ''
          return trimmed_description = before_divider( trimmed_description )
        end
        return nil
      end

      def name
        return @name if @name
        # Triangulate with Title, Heading, Keywords, Description, Facebook, Twitter, TripAdvisor, Yelp, Google
        guesses = []
        guesses << reject_long( before_divider( title ) , 8, 33)
        guesses << reject_long( before_divider( meta_name ) , 8, 33)
        guesses << reject_long( trimmed_keyword , 8, 33)
        guesses << reject_long( trimmed_description , 8, 33)
        guesses << reject_long( before_divider( details_name ) , 8, 33)
        guesses << reject_long( before_divider( heading ) , 8, 35)
        guesses << before_divider( facebook )
        guesses << before_divider( twitter )
        guesses << before_divider( tripadvisor )
        guesses << before_divider( yelp )
        guesses << before_divider( google )

        guesses = delete_items_from_array_case_insensitive(list_of_null_page_titles, guesses).compact
        guesses = delete_items_from_array_case_insensitive([locality, region, country], guesses).compact
        guesses = delete_items_from_array_case_insensitive([lowercase_destination_class, lowercase_destinations_plural_class], guesses).compact


        #ensure that name is *on* the page
        new_array = []
        guesses.each do |guess|
          new_array << guess unless ( !page.text || !page.text.include?(guess) ) && ( !heading || !heading.include?(guess) )
        end
        guesses = new_array

        if clear_choice = top_pick(guesses.compact, 0.50001)[:is]
          return @name = clear_choice
        elsif muddy_choice = dominant_pick(guesses.compact)
          return @name = muddy_choice unless ( !page.text || !page.text.include?(muddy_choice) ) && ( !heading || !heading.include?(muddy_choice) )
        end
        return nil
      end

    end
  end
end