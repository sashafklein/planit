module Scrapers
  module GeneralMod

    # PAGE SETUP

    class Attempt < General

      attr_accessor :locality, :region, :postal_code, :country, :street_address, :nearby
      def initialize(url, page)
        super(url, page)
      end

      # PAGE 

      def data
        # run general page scrapers
        meta_contact
        set_locale
        # binding.pry
        [ place: {
            name: name,
            street_address: street_address,
            locality: locality,
            region: region,
            postal_code: postal_code,
            country: country,
            phones: phone,
            lat: lat,
            lon: lon,
            hours: hours,
            nearby: nearby,
            # images: images,
          }
        ]
      end

      # OPERATIONS

      # DOES IT HAVE MAP LINKS? PARSE LINKS, LINK TEXT

      def map_attempts # ADD OTHER MAP SERVICES? BING? MAPBOX?
        [
          "www.google.com/maps/", # e.g. https://www.google.com/maps/place/124+Columbus+Ave/@37.7967858,-122.4048005,17z/data=!3m1!4b1!4m2!3m1!1s0x808580f4dc5c4831:0x1bea4997be9969cf
          "maps.google.com/maps?", # e.g. http://maps.google.com/maps?f=q&source=s_q&hl=en&geocode=&q=contigo+1320+castro+street,+san+francisco,+ca+94114&sll=37.0625,-95.677068&sspn=62.870523,55.898438&ie=UTF8&z=17&iwloc=A
        ]
      end

      def map_images
        image_array = []
        page_map_images = page.css("img")
        page_map_images.each_with_index do |image, index|
          alt = image.attribute("alt").value unless !image.attribute("alt")
          src = image.attribute("src").value unless !image.attribute("src")
          map_attempts.each do |attempt|          
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
          map_attempts.each do |attempt|          
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

      def title
        return @title if @title
        @title = trim( page.css("title").text ) 
      # rescue; nil
      end

      def heading
        return @heading if @heading
        if h1 = page.css("h1").first
          return @heading = trim( h1.text )  
        end
        return nil
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
        if meta_tag = page.css("meta[property='og:title']").first
          return @meta_name = meta_tag.attribute("content").value
        elsif meta_tag = page.css("meta[itemprop='name']").first
          return @meta_keywords = meta_tag.attribute("content").value
        end
        return nil
      # rescue; nil
      end

      def google
        return @google if @google
        if map_string
          map_string.each do |string|
            query = string
            # clean up before query
            query = query.gsub(/.*\.com\/maps/, '') || ''
            query = query.gsub(/.*\/place\//, '') || ''
            query = query.gsub(/.*[qQ]\=/, '')
            # clean up after query
            query = query.gsub(/\+\+.*/, '') || ''
            query = query.gsub(/\/\@.*/, '') || ''
            query = query.gsub(/\&.*/, '') || ''
            # fix spacing
            query = query.gsub("+", " ") || ''
            query = query.gsub("%20", " ") || ''
            query = query.gsub("%2C", ",") || ''
            # take out address starting with numbers
            query = query.gsub(/\d+ (?:\w|\d+).*/, '') || ''
            query = query.titleize
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
        unless @twitter
          if meta = page.css("meta[name='twitter:title']").first
            if meta.attribute("content")
              return @twitter = meta.attribute("content").value
            end
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
              return @facebook = title_match unless title_match && title_match.downcase == "us"
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
          if text = link.text.include?("facebook")
            if text
              @facebook_href = link.attribute("href").value
              text_match = text.scan(/(?:Become a fan of |\A)(.*?) on Facebook/).flatten.first
              return @facebook = text_match unless text_match && text_match.downcase == "us"
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

      def meta_contact
        meta_street_address
        meta_locality
        meta_region
        meta_country
        meta_postal_code
      end

      def meta_street_address
        return @street_address if @street_address
        if meta_tag = page.css("meta[property='street_address']").first
          return @street_address = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def meta_locality
        return @locality if @locality
        if meta_tag = page.css("meta[property='locality']").first
          return @locality = trim( meta_tag.attribute("content").value ) 
        elsif meta_tag = page.css("meta[property='city']").first
          return @locality = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def meta_region
        return @region if @region
        if meta_tag = page.css("meta[property='region']").first
          return @region = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def meta_phone
        return @phone if @phone
        if meta_tag = page.css("meta[property='phone']").first
          return @phone = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='phone_number']").first
          return @phone = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='phoneNumber']").first
          return @phone = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def meta_postal_code
        return @postal_code if @postal_code
        if meta_tag = page.css("meta[property='postal_code']").first
          return @postal_code = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='postalCode']").first
          return @postal_code = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='zip_code']").first
          return @postal_code = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='zipCode']").first
          return @postal_code = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='zipcode']").first
          return @postal_code = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def meta_country
        return @country if @country
        if meta_tag = page.css("meta[property='country']").first
          return @country = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='addressCountry']").first
          return @country = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='country_name']").first
          return @country = trim( meta_tag.attribute("content").value )
        elsif meta_tag = page.css("meta[property='countryName']").first
          return @country = trim( meta_tag.attribute("content").value )
        end
        return nil
      # rescue ; nil
      end

      def full_address
        return @full_address if @full_address
        # first if clean address already exists
        if @street_address && @locality && @region && @country
          return @full_address = [@street_address, @locality, @region, @country].join(", ")
        elsif @street_address && @locality && @country
          return @full_address = [@street_address, @locality, @country].join(", ")
        elsif map_string
          # via map link
          map_string.each do |string|
            query = string
            # clean up before query
            query = query.gsub(/.*\.com\/maps/, '') || ''
            query = query.gsub(/.*\/place\//, '') || ''
            query = query.gsub(/.*\&q\=/, '') || ''
            # clean up after query
            query = query.gsub(/\+\+.*/, '') || ''
            query = query.gsub(/\/\@.*/, '') || ''
            query = query.gsub(/\&.*/, '') || ''
            # take out venue name
            query = query.gsub(/\A#{name}/, '') || ''
            # fix spacing
            query = query.gsub("+", " ") || ''
            query = query.gsub("%20", " ") || ''
            query = query.gsub("%2C", ",") || ''
            query = query.titleize
            return @full_address = query
          end
        end
      # rescue ; nil
      end

      # def detail_box
      #   return @detail_box if @detail_box
      #   attempts = [
      #     ".contact",
      #     "#contact",
      #     ".contact-info",
      #     "#contact-info",
      #     ".contact_info",
      #     "#contact_info",
      #     ".contact-info",
      #     "#contact-info",
      #     "adr",
      #     ".adr",
      #     "#adr",
      #     "address",
      #     ".address",
      #     "#address",
      #     ".address-info",
      #     "#address-info",
      #     ".address_info",
      #     "#address_info",
      #     ".address-info",
      #     "#address-info",
      #     "location",
      #     ".location",
      #     "#location",
      #     ".propertyAddress",
      #     "#propertyAddress",
      #     ".property-address",
      #     "#property-address",
      #     ".property_address",
      #     "#property_address",
      #     "span[itemprop='contact']",
      #     "span[itemprop='contact-info']",
      #     "span[itemprop='contact_info']",
      #     "span[itemprop='contactinfo']",
      #     "span[itemprop='address']",
      #     "span[itemprop='address-info']",
      #     "span[itemprop='address_info']",
      #     "span[itemprop='addressinfo']",
      #   ]
      #   attempts.each do |attempt|
      #     if detail_attempt = page.css(attempt).first
      #       return @detail_box = detail_attempt
      #     end
      #   end
      #   return nil
      # end

      def details_name
        return @details_name if @details_name
        attempts = [
          "[itemprop='name']",
          "[itemprop='title']",  
          "[property='v:name']",
          "[property='v:title']",
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @details_name = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @details_name = trim( de_tag( object.inner_html ) )
            end
          end
        end
        return nil
      end


      def street_address
        return @street_address if @street_address
        attempts = [
          "[itemprop='streetAddress']",
          "[itemprop='street_address']",
          "[itemprop='street-address']",
          "[itemprop='streetaddress']",
          "[itemprop='address']",          
          "[property='v:streetAddress']",
          "[property='v:street_address']",
          "[property='v:street-address']",
          "[property='v:streetaddress']",
          "[property='v:address']",          
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @street_address = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @street_address = trim( de_tag( object.inner_html ) )
            end
          end
        end
        return nil
      end

      def country
        return @country if @country
        attempts = [
          "[itemprop='countryName']",
          "[itemprop='country_name']",
          "[itemprop='country-name']",
          "[itemprop='countryname']",
          "[itemprop='country']",          
          "[itemprop='addressCountry']",          
          "[itemprop='address_country']",          
          "[itemprop='address-country']",          
          "[property='v:countryName']",
          "[property='v:country_name']",
          "[property='v:country-name']",
          "[property='v:countryname']",
          "[property='v:country']",          
          "[property='v:addressCountry']",          
          "[property='v:address_country']",          
          "[property='v:address-country']",          
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @country = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @country = trim( de_tag( object.inner_html ) )
            end
          end
        end
        return nil
      end

      def postal_code
        return @postal_code if @postal_code
        attempts = [
          "[itemprop='postalCode']",
          "[itemprop='postal_code']",
          "[itemprop='postal-code']",
          "[itemprop='postalcode']",
          "[itemprop='zipCode']",          
          "[itemprop='zip_code']",          
          "[itemprop='zip-code']",          
          "[itemprop='zipcode']",          
          "[property='v:postalCode']",
          "[property='v:postal_code']",
          "[property='v:postal-code']",
          "[property='v:postalcode']",
          "[property='v:zipCode']",
          "[property='v:zip_code']",
          "[property='v:zip-code']",
          "[property='v:zipcode']",
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @postal_code = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @postal_code = trim( de_tag( object.inner_html ) )
            end
          end
        end
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
        attempts = [
          "[itemprop='telephone']",
          "[itemprop='phone']",
          "[itemprop='phone_number']",
          "[itemprop='phone-number']",
          "[itemprop='phoneNumber']",          
          "[itemprop='mobile']",          
          "[property='v:telephone']",
          "[property='v:phone']",
          "[property='v:phone_number']",
          "[property='v:phone-number']",
          "[property='v:phoneNumber']",
          "[property='v:mobile']",
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @phone = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @phone = trim( de_tag( object.inner_html ) )
            end
          end
        end
        return nil
      # rescue ; nil
      end

      def set_locale
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
        attempts = [
          "[itemprop='lat']",
          "[itemprop='latitude']",
          "[property='v:lat']",
          "[property='v:latitude']",
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @lat = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @lat = trim( de_tag( object.inner_html ) )
            end
          end
        end
        # if page.css("[data-lat]")
        # elsif page.css("[data-latitude]")
        # end
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
        attempts = [
          "[itemprop='lon']",
          "[itemprop='lng']",
          "[itemprop='long']",
          "[itemprop='longitude']",
          "[property='v:lon']",
          "[property='v:lng']",
          "[property='v:long']",
          "[property='v:longitude']",
        ]
        attempts.each do |attempt|
          if object = page.css(attempt).first
            if object.attribute("content")
              return @lon = trim( object.attribute("content").value )
            elsif object.inner_html && object.inner_html.length > 0
              return @lon = trim( de_tag( object.inner_html ) )
            end
          end
        end
        # if page.css("[data-lon]")
        # elsif page.css("[data-lng]")
        # elsif page.css("[data-long]")
        # elsif page.css("[data-longitude]")
        # end
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
          trimmed_keyword = meta_keywords.gsub(/,.*/, '')
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

        if clear_choice = top_pick(guesses.compact)[0]
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