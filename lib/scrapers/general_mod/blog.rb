module Scrapers
  module GeneralMod

    # PAGE SETUP

    class Blog < General

      attr_accessor :locality, :region, :postal_code, :country, :street_address, :nearby
      def initialize(url, page)
        super(url, page)
      end

      # PAGE 

      def data
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
        image_array = []
        page_map_images = page.css("img")
        page_map_images.each_with_index do |image, index|
          alt = image.attribute("alt").value unless !image.attribute("alt")
          src = image.attribute("src").value unless !image.attribute("src")
          map_link_src_usual_suspects.each do |attempt|          
            if src && src.include?(attempt)
              image_array << [index, alt, src]
            end
          end
        end
        if image_array && image_array.length > 0 && image_array.compact.uniq{ |a| a[2] }.length == 1
          return [return_link_and_text(image_array)]
        elsif image_array && image_array.length > 0 && image_array.compact.uniq{ |a| a[2] }.length > 1 
          to_return = []
          images_index = image_array.compact.uniq{ |a| a[2] }
          images_index.each do |image_to_index|
            sub_array = image_array.map{ |e| e[2]==image_to_index }
            to_return << return_link_and_text(sub_array)
          end
        end          
      # rescue ; nil
      end

      def map_links
        link_array = []
        page_map_links = page.css("a")
        page_map_links.each_with_index do |link, index|
          text = link.text
          href = link.attribute("href").value unless !link.attribute("href")
          map_link_src_usual_suspects.each do |attempt|          
            if href && href.include?(attempt)
              link_array << [index, text, href]
            end
          end
        end
        if link_array && link_array.length > 0 && link_array.compact.uniq{ |a| a[2] }.length == 1
          return [return_link_and_text(link_array)]
        elsif link_array && link_array.length > 0 && link_array.compact.uniq{ |a| a[2] }.length > 1 
          to_return = []
          links_index = link_array.compact.uniq{ |a| a[2] }
          links_index.each do |link_to_index|
            sub_array = link_array.map{ |e| e[2]==link_to_index }
            to_return << return_link_and_text(sub_array)
          end
        end          
      # rescue ; nil
      end

      def return_link_and_text(link_array)
        link_text = link_array.sort_by {|x| x[1].length}.last[1]
        link_array.sort_by {|x| x[0] }
        link_array.each do |link|
          if !link_text.include? trim(link[1])
            link_text += link[1]
          end
        end
        return link_text, link_array.first[2]
      # rescue ; nil
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
      # rescue ; nil
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
      # rescue ; nil
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
      # rescue ; nil
      end

      def yelp
      # rescue ; nil
      end

      def tripadvisor
      end

      # META DATA SCRAPING

      def title
        return @title if @title
        @title = trim( page.css("title").text ) 
      # rescue; nil
      end

      def meta_description
        return @meta_description if @meta_description
        if meta_tag = page.css("meta[name='description']").first
          return @meta_description = meta_tag.attribute("content").value
        end
        return nil
      # rescue; nil
      end

      def meta_keywords
        return @meta_keywords if @meta_keywords
        if meta_tag = page.css("meta[name='keywords']").first
          return @meta_keywords = meta_tag.attribute("content").value
        end
        return nil
      # rescue; nil
      end

      def meta_name
        return @meta_name if @meta_name
        return @meta_name = get_usual_suspect_text(meta_name_usual_suspects)
        return nil
      # rescue; nil
      end

      # ON PAGE DATA SCRAPING

      def heading
        return @heading if @heading
        return @heading = get_usual_suspect_text(heading_usual_suspects)
        return nil
      # rescue; nil
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
      # rescue ; nil
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
      # rescue ; nil
      end

      def nearby
        return @nearby if @nearby
        unless lat && lon
          if @locality && @country
            return @nearby = [@locality, @region, @country].join(", ")
          else
            # scan page at meta tags, title and text-level
            keyword_guesses = guess_locale( meta_keywords )
            description_guesses = guess_locale( meta_description )
            title_guesses = guess_locale( title )
            page_guesses = guess_locale_rough( page.text )
            # shovel guesses in, chose top
            unless @locality
              locality_guesses = []
              locality_guesses << keyword_guesses[0] unless !keyword_guesses
              locality_guesses << title_guesses[0] unless !title_guesses
              locality_guesses << description_guesses[0] unless !description_guesses
              locality_guesses << page_guesses[0] unless !page_guesses
              @locality = top_pick(locality_guesses)[0]
            end
            unless @region
              region_guesses = []
              region_guesses << keyword_guesses[1] unless !keyword_guesses
              region_guesses << title_guesses[1] unless !title_guesses
              region_guesses << description_guesses[1] unless !description_guesses
              region_guesses << page_guesses[1] unless !page_guesses
              @region = top_pick(region_guesses)[0]
            end
            unless @country
              country_guesses = []
              country_guesses << keyword_guesses[2] unless !keyword_guesses
              country_guesses << title_guesses[2] unless !title_guesses
              country_guesses << description_guesses[2] unless !description_guesses
              country_guesses << page_guesses[2] unless !page_guesses
              @country = top_pick(country_guesses)[0]
            end
            return @nearby = [@locality, @region, @country].compact.join(", ")
          end
        end
      # rescue ; nil
      end

      def map_href
        return @map_href if @map_href
        map_links ? @map_href = map_links.map{ |l| l.last } : nil
      end

      def map_string
        return @map_string if @map_string
        map_string_array = []
        if map_links
          map_links.each do |map|
            map_string_array << map.last
          end
          return @map_string = map_string_array
        elsif map_images
          map_images.each do |map|
            map_string_array << map.last
          end
          return @map_string = map_string_array
        end
      # rescue ; nil
      end

      def lat
        return @lat if @lat
        if map_string
          map_string.each do |string|
            string = string.gsub("%2C", ",") || ''
            latlon = string.scan(/[,&@=\/]([-]?\d+\.\d+\,[-]?\d+\.\d+)[,&@]/).flatten.first
            return @lat = latlon.split(",")[0] unless !latlon
          end
        end
        if lat_on_page = get_usual_suspect_text(latitude_usual_suspects)
          return @lat = lat_on_page
        end
        return nil
      # rescue ; nil
      end

      def lon
        return @lon if @lon
        if map_string
          map_string.each do |string|
            string = string.gsub("%2C", ",") || ''
            latlon = string.scan(/[,&@=\/]([-]?\d+\.\d+\,[-]?\d+\.\d+)[,&@]/).flatten.first
            return @lon = latlon.split(",")[1] unless !latlon
          end
        end
        if lon_on_page = get_usual_suspect_text(longitude_usual_suspects)
          return @lon = lon_on_page
        end
        return nil
      # rescue ; nil
      end

      def hours
        # %w(.hours #hours)
      end

      def name
        return @name if @name
        # Triangulate with Title, Heading, Keywords, Description, Facebook, Twitter, TripAdvisor, Yelp, Google
        guesses = []
        # trim down sub-titles etc
        if meta_keywords
          trimmed_keyword = meta_keywords.gsub(/\,.*/, '')
          trimmed_keyword = before_divider( trimmed_keyword )
        end
        if meta_description
          trimmed_description = meta_description
          trimmed_description = trimmed_description.gsub(/ is a .*/, '') || ''
          trimmed_description = trimmed_description.gsub(/ is the .*/, '') || ''
          trimmed_description = before_divider( trimmed_description )
        end
        # build guess array
        guesses << before_divider( title )
        guesses << before_divider( meta_name )
        guesses << trimmed_keyword
        guesses << trimmed_description
        guesses << before_divider( details_name )
        guesses << before_divider( heading )
        guesses << before_divider( facebook )
        guesses << before_divider( twitter )
        guesses << before_divider( tripadvisor )
        guesses << before_divider( yelp )
        guesses << before_divider( google )

        @name_guesses = guesses

        delete_items_from_array_case_insensitive(list_of_null_page_titles, guesses)

        if clear_choice = top_pick(guesses.compact, 0.4999)[0]
          return @name = clear_choice
        else
          # remove common destination suffix/prefixes
          new_array = []
          guesses.compact.each do |guess|
            guess = trim( guess.downcase.gsub(/#{lowercase_destination_class}/, '') ) unless !guess
            guess = trim( guess.downcase.gsub(/#{lowercase_destinations_plural_class}/, '') ) unless !guess
            new_array << guess
          end
          guesses = new_array
          # reset new_array and remove locality only / country only / region only
          new_array = []
          guesses.compact.each do |guess|
            guess = trim( guess.downcase.gsub(/\A#{locality.downcase}\Z/, '') ) unless !guess || !locality
            guess = trim( guess.downcase.gsub(/\A#{region.downcase}\Z/, '') ) unless !guess || !region
            guess = trim( guess.downcase.gsub(/\A#{country.downcase}\Z/, '') ) unless !guess || !country
            new_array << guess unless guess == ''
          end
          guesses = new_array
          if ok_choice = top_pick(guesses, 0.2)[0]
            return @name = ok_choice.titleize
          end
        end
      # rescue ; nil
      end

      def before_divider(string)
        trimmed = string
        trimmed = trimmed.gsub(/[ ]{3}.*/, '') unless !trimmed
        trimmed = trimmed.gsub(/ \- .*/, '') unless !trimmed
        trimmed = trimmed.gsub(/\:.*/, '') unless !trimmed
        trimmed = trimmed.gsub(/\;.*/, '') unless !trimmed
        trimmed = trimmed.gsub(/\/.*/, '') unless !trimmed
        trimmed = trimmed.gsub(/\|.*/, '') unless !trimmed
        return trim( trimmed ) unless trimmed == '' || !trimmed
        return nil
      end

      def name_attempts
        name
        return @name_guesses
      end

    end
  end
end