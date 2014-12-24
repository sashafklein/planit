module Scrapers
  module EmailMod

    # PAGE SETUP

    class Tips < Email

      attr_accessor :locality, :region, :postal_code, :country, :street_address, :nearby
      def initialize(url, page)
        super(url, page)
      end

      # PAGE 

      def data
        binding.pry
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
            website: more_info_website,
            # images: images,
          }
        ]
      end

      # OPERATIONS

      # Set article body box

      def article_box
        get_usual_suspect_text(article_usual_suspects)
      end

      # Scan for more/story info section, if not separate, find & segregate in article body

      def more_info_box
        get_usual_textspect_html(details_box_usual_textspects)
      end

      def more_info_lines
        if more_info_box && more_info_box.length > 0
          if lines = more_info_box.split(%r!(?:\<[/]?[p]\>|\<[/]?[br]\>|\n|\r)!)
            return lines.compact.reject!(&:blank?)
          end
        end
        return nil
      end

      def more_info_name
        if more_info_lines
          signal = %r!(?:Where|where|WHERE)[: ]!
          more_info_lines.each do |line|
            if line.match(signal)
              matching_line = de_tag( line ).split(line.scan(signal).flatten.first)[1]
              return trim matching_line.scan(/(.*?)[,.;(]/).flatten.first
            end
          end
        end
      end

      def more_info_address
        if more_info_lines
          signal = %r!(?:Where|where|WHERE)[: ]!
          more_info_lines.each do |line|
            if line.match(signal)
              matching_line = de_tag( line ).split(line.scan(signal).flatten.first)[1]
              matching_line = trim( matching_line.gsub(/(?:#{phone_number_thread})/, '') )
              matching_line = trim( matching_line.gsub(/(#{is_website_link?})/, '') )
              matching_line = trim( matching_line.gsub(/\A#{name}/, '') )
              return trim( matching_line.scan(/[,.;( ]*(.*?)[,.;( ]*/).flatten.first )
            end
          end
        end
      end

      def more_info_website
        if more_info_box
          if punctuated = trim( more_info_box.scan(%r!(#{is_website_link?})!).flatten.first )
            return punctuated.scan(remove_final_punctuation_regex).flatten.first
          end
        end
        return nil
      end

      def more_info_phone
        if more_info_box
          more_info_box.gsub(/\d\d\d\d\d(?:-| )?(?:\d\d\d\d)/, '') # trim zip code out?
          if punctuated = trim( more_info_box.scan(%r!(#{phone_number_thread})!).flatten.first )
            return punctuated.scan(remove_final_punctuation_regex).flatten.first
          end
        end
        return nil
      end

      # Scan for info-packets (e.g. details in parens)
      # Scan for links starting with at &/or preceeded by destinations (comma/colon optional)
      # Scan for other links
      # Clean article text, return in sections

      # DOES IT HAVE MAP LINKS? PARSE LINKS, LINK TEXT

      def at_place(text)
        at_strings = text.scan(/(?:#{normal_punctuation_thread}[Aa]|\A[A]| [Aa])t (#{title_or_upper_cased_or_exceptions_thread})/).flatten
        if pick = top_pick(at_strings.compact, 0.85)
          return pick.first
        end
        return nil
      end

      def in_locale(text)
        in_strings = text.scan(/(?:#{normal_punctuation_thread}[Ii]|\A[I]| [Ii])n (#{title_or_upper_cased_or_exceptions_thread})/).flatten
        if pick = top_pick(in_strings.compact, 0.35)
          return pick.first
        end
        return nil
      end

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
        if more_info_address
          return @full_address = more_info_address
        end
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
        if phone_usual = get_usual_suspect_text(phone_usual_suspects)
          return @phone = phone_usual
        elsif more_info_phone
          return @phone = more_info_phone
        end
        return nil
      end

      def nearby
        return @nearby if @nearby
        unless lat && lon
          if @locality && @country
            return @nearby = [@locality, @region, @country].join(", ")
          else
            # scan page at meta tags, title and text-level, ALSO INFOBOX
            in_locale_guesses = guess_locale( in_locale(article_box) )
            details_guesses = guess_locale( more_info_box )
            keyword_guesses = guess_locale( meta_keywords )
            description_guesses = guess_locale( meta_description )
            title_guesses = guess_locale( title )
            page_guesses = guess_locale_rough( page.text )
            # shovel guesses in, chose top
            unless @locality
              locality_guesses = []
              locality_guesses << in_locale_guesses[0] unless !in_locale_guesses
              locality_guesses << details_guesses[0] unless !details_guesses
              locality_guesses << keyword_guesses[0] unless !keyword_guesses
              locality_guesses << title_guesses[0] unless !title_guesses
              locality_guesses << description_guesses[0] unless !description_guesses
              # locality_guesses << page_guesses[0] unless !page_guesses
              @locality = top_pick(locality_guesses)[0]
            end
            unless @region
              region_guesses = []
              locality_guesses << in_locale_guesses[1] unless !in_locale_guesses
              locality_guesses << details_guesses[1] unless !details_guesses
              region_guesses << keyword_guesses[1] unless !keyword_guesses
              region_guesses << title_guesses[1] unless !title_guesses
              region_guesses << description_guesses[1] unless !description_guesses
              # region_guesses << page_guesses[1] unless !page_guesses
              @region = top_pick(region_guesses)[0]
            end
            unless @country
              country_guesses = []
              locality_guesses << in_locale_guesses[2] unless !in_locale_guesses
              locality_guesses << details_guesses[2] unless !details_guesses
              country_guesses << keyword_guesses[2] unless !keyword_guesses
              country_guesses << title_guesses[2] unless !title_guesses
              country_guesses << description_guesses[2] unless !description_guesses
              # country_guesses << page_guesses[2] unless !page_guesses
              @country = top_pick(country_guesses)[0]
            end
            return @nearby = [@locality, @region, @country].compact.join(", ")
          end
        end
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
        guesses << reject_long( at_place( article_box ) , 8, 25)
        guesses << reject_long( more_info_name , 8, 25)
        guesses << reject_long( before_divider( title ) , 8, 25)
        guesses << reject_long( before_divider( meta_name ) , 8, 25)
        guesses << reject_long( trimmed_keyword , 8, 25)
        guesses << reject_long( trimmed_description , 8, 25)
        guesses << reject_long( before_divider( details_name ) , 8, 25)
        guesses << reject_long( before_divider( heading ) , 8, 25)
        guesses << reject_long( before_divider( facebook ) , 8, 25)
        guesses << reject_long( before_divider( twitter ) , 8, 25)
        guesses << reject_long( before_divider( tripadvisor ) , 8, 25)
        guesses << reject_long( before_divider( yelp ) , 8, 25)
        guesses << reject_long( before_divider( google ) , 8, 25)

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