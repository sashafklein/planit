module Scrapers
  module GeneralMod

    # PAGE SETUP

    class Article < General

      attr_accessor :locality, :region, :postal_code, :country, :street_address, :nearby
      def initialize(url, page)
        super(url, page)
      end

      # PAGE  

      def data
        if nearby && name && names.length == 1
          [ place: {
              lat: lat,
              lon: lon,
              nearby: nearby,
              name: name,
              full_address: full_address,
              street_address: street_address,
              locality: locality,
              region: region,
              postal_code: postal_code,
              country: country,
              phones: phone,
              hours: hours,
              website: trim_url( more_info_website ),
              map_href: map_href,
            },
            scraper_url: @url,
          ]
        elsif nearby && name && names.length > 1
          names.each do |instance|
            @data << full_item([
              place: {
                nearby: nearby,
                name: instance,
                full_address: find_address_by_name(instance),
                locality: locality,
                region: region,
                country: country,
                phone: find_phone_by_name(instance),
                website: trim_url( find_website_by_name(instance) ),
              },
              scraper_url: @url,
            ])
          end
          return @data
        else
          return nil
        end
      end

      # OPERATIONS

      # Set article body box

      def article_text
        article_object.text
      end

      # Scan for more/story info section, if not separate, find & segregate in article body

      def more_info_box
        html = get_usual_textspect_html(details_box_usual_textspects)
        0.upto(illegal_content.length - 1).each do |i|
          html = html.gsub(%r!#{illegal_content[i]}!, '') unless !html
        end
        return html
      end

      def more_info_lines
        if more_info_box && more_info_box.length > 0
          if lines = more_info_box.split(%r!(?:\<[/]?[p]\>|\<[/]?[br]\>|\n|\r)!)
            return lines.compact.reject(&:blank?)
          end
        end
        return nil
      end

      def more_info_signal
        %r!(?:Where|where|WHERE|Info|info|INFO)[: ]!
      end

      def more_info_names
        names_array = []
        if more_info_lines
          more_info_lines.each do |line|
            if line.match(more_info_signal)
              matching_line = de_tag( line ).split(line.scan(more_info_signal).flatten.first)[1]
              names_array << trim( matching_line.scan(/(.*?)[,.;(]/).flatten.first )
            elsif strong_result = line.scan(/#{b_or_strong_open_thread}\s*(.*?)\s*#{b_or_strong_close_thread}/)
              if strong_result.length > 0
                strong_result.flatten.each do |e|
                  names_array << trim(legal_strong_results(e)) unless !legal_strong_results(e)
                end
              end
            end
          end
          return names_array.compact
        end
        return nil
      end

      def more_info_address
        if more_info_lines && more_info_names && more_info_names.length == 1
          more_info_lines.each do |line|
            if line.match(more_info_signal)
              matching_line = de_tag( line ).split(line.scan(more_info_signal).flatten.first)[1]
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
          return pick[:is]
        end
        return nil
      end

      def article_object
        article_usual_suspects.each do |attempt|
          if object = page.css(attempt).last
            return object
          end
        end
        return nil
      end

      def article_paragraphs
        if article_paragraphs = article_object.css("p")
          return article_paragraphs
        end
        return nil
      end

      def linked_places_in_article_body
        link_names = []
        article_paragraphs.each do |paragraph|
          links_in_paragraph = paragraph.css("a")
          links_in_paragraph.each do |link_in_paragraph|
            if link_in_paragraph.attribute("href") && href = link_in_paragraph.attribute("href").value
              if !href.match(/(?:#{prohibited_link_to_name_domains.join("\\.|")}\.)/) && !href.match(/#{link_in_paragraph.text}/) && href.match(/\A#{is_website_link?}\Z/) #verify real site / not internal or non-functioning
                link_names << reject_long( get_allowable_link_text(link_in_paragraph) ) unless !get_allowable_link_text(link_in_paragraph)
              end
            end
          end
        end
        if link_names.compact.length > 5 && top_pick(link_names.compact, 0.85).length > 0
          return [top_pick(link_names.compact, 0.85).first]
        elsif link_names.length > 0
          return link_names.compact
        end
        return nil
      end

      def get_allowable_link_text(link_object)
        if link_object.text.match(/\s*#{is_website_link?}\s*/)
          return nil
        else
          if link_object.text
            result = trim( link_object.text.gsub(/(?:#{prohibited_link_to_name_text_list.join("|")})/, '') )
            return result unless result == ''
          end
        end
        return link_object.text
      end

      def in_locale(text)
        in_strings = text.scan(/(?:#{normal_punctuation_thread}[Ii]|\A[I]| [Ii])n (#{title_or_upper_cased_or_exceptions_thread})/).flatten
        if pick = top_pick(in_strings.compact, 0.35)
          return pick[:is]
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

      def facebook
        return @facebook if @facebook
        facebook_names = []
        article_object.css("a").each do |link|
          if href = link.attribute("href")
            if href.value.match(/.*facebook.com\/pages.*/)
              @facebook_href = link.attribute("href").value
              href_match = href.value.scan(/pages\/.*?\//).flatten.first
              href_match = href_match.gsub("-", " ") || ''
              href_match = href_match.titleize
              facebook_names << href_match unless href_match == ""
            end
          end
        end
        return facebook_names unless facebook_names.length == 0
        return []
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
        if nearby && name && names.length == 1
          return @full_address = find_address_by_name(name) unless !find_address_by_name(name)
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

      def host_domain
        myUri = URI.parse( url )
        return myUri.host
      end

      def nearby
        return @nearby if @nearby
        unless lat && lon
          page_content_to_scan = [ in_locale(article_box), more_info_box, meta_keywords, meta_description, title, page.text ]
          guesses = page_content_to_scan.map{ |content| guess_locale( content ) }
          @locality ||= top_pick( guesses.compact.map{ |g| g[:locality] } )[:is]
          @region ||= top_pick( guesses.compact.map{ |g| g[:region] } )[:is]
          @country ||= top_pick( guesses.compact.map{ |g| g[:country] } )[:is]
          @nearby = [@locality, @region, @country].compact.join(", ")
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

      def names
        return @names if @names
        return [name] if name.class == String
        return name if name.class == Array
        return nil
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
        # Triangulate with Title, Heading, Keywords, Description, Links, Facebook, Twitter, TripAdvisor, Yelp, Google
        guesses = []
        guesses << reject_long( at_place( article_text ) , 8, 25)
        if more_info_names
          more_info_names.each do |more_info_name|
            guesses << trim( reject_long( more_info_name , 8, 25) )
          end
        end
        guesses << reject_long( before_divider( title ) , 8, 25)
        guesses << reject_long( before_divider( meta_name ) , 8, 25)
        guesses << reject_long( trimmed_keyword , 8, 25)
        guesses << reject_long( trimmed_description , 8, 25)
        guesses << reject_long( before_divider( details_name ) , 8, 25)
        guesses << reject_long( before_divider( heading ) , 8, 25)
        if facebook
          facebook.each do |facebook_place|
            guesses << trim( reject_long( before_divider( facebook_place ) , 8, 25) )
          end
        end

        if guesses.compact.uniq.length != 1
          if linked_places_in_article_body
            linked_places_in_article_body.each do |linked_place|
              guesses << trim( reject_long( before_divider( linked_place ) , 8, 25) )
            end
          end
        end

        guesses = delete_items_from_array_case_insensitive(list_of_null_page_titles, guesses).compact
        guesses = delete_items_from_array(["(?:[Ff]ly.|[Tt]ravel.|[Dd]rive.)?(?:[Ff]rom.|[Vv]ia.)[A-Z]{3}"], guesses).compact
        guesses = delete_items_from_array_case_insensitive([locality, region, country], guesses).compact unless !nearby
        guesses = delete_items_from_array_case_insensitive([lowercase_destination_class, lowercase_destinations_plural_class], guesses).compact

        #ensure that name is *on* the page
        new_array = []
        guesses.each do |guess|
          new_array << guess unless ( !article_text || !article_text.include?(guess) ) && ( !heading || !heading.include?(guess) )
        end
        guesses = new_array

        if clear_choice = top_pick(guesses.compact, 0.50001)[:is]
          return @name = clear_choice
        else
          return @names = guesses.compact.uniq        
        end
      end

      def searchable_text
        text = ""
        text += " . " + de_tag( heading ) unless !heading
        text += " . " + article_text unless !article_text 
        text += " . " + de_tag( more_info_box ) unless !more_info_box
        return text
      end

      def find_website_by_name(instance)
        cased(instance).each do |instance_cased|
          if link = page.css("a:contains('#{instance_cased}')")
            if link.first && website_result = link.first.attribute('href').value
              if !website_result.include?(host_domain)
                return website_result
              end
            end
          end
          if website_result = searchable_text.scan( find_website_by_name_multiple_attempts_regex(instance_cased) ).flatten.compact.first
            if !website_result.include?(host_domain)
              return website_result
            end
          end
        end
        return nil
      end

      def find_phone_by_name(instance)
        cased(instance).each do |instance_cased|
          if address_result = searchable_text.scan( find_phone_by_name_multiple_attempts_regex(instance_cased) ).flatten.compact.first
            return trim address_result
          end
        end
        return nil
      end

      def find_address_by_name(instance)
        cased(instance).each do |instance_cased|
          if address_result = searchable_text.scan( find_address_by_name_multiple_attempts_regex(instance_cased) ).flatten.compact.first
            return trim address_result
          end
        end
        return nil
      end

      def legal_strong_results(string)
        prohibited_strong_results.each do |result|
          if string.match(/\A(?:#{cased(result).join("|")})[:]?\Z/)
            return nil
          end
        end
        return string
      end

    end
  end
end