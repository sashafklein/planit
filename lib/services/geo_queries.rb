module Services
  module GeoQueries
    
    def find_country(string)
      if string
        country = Carmen::Country.all.find{ |c| no_accents(string).downcase.include?(no_accents(c.name.downcase)) }
        country ||= Carmen::Country.all.find{ |c| (string).include?("#{c.alpha_3_code.titleize}.") } 
        country ||= Carmen::Country.all.find{ |c| (string).include?(c.alpha_3_code.upcase) } 
        country.try(:name)
      end    end

    def find_country_by_code(string)
      if string
        country ||= Carmen::Country.all.find{ |c| (string.upcase).include?(c.code.upcase) } 
        country.try(:name)
      end    end

    def find_region(string, country)
      if string && country
        carmen_country = Carmen::Country.named(country)
        region = carmen_country.subregions.find{ |sr| no_accents(string.downcase).include?(no_accents(sr.name.downcase)) }
        region ||= carmen_country.subregions.find{ |sr| no_accents(string).include?("#{no_accents(sr.name).first(3)}.") }
        region ||= carmen_country.subregions.find{ |sr| string.include?(sr.code.upcase) }
        region.try(:name)
      end    end

    def find_country_strict(string)
      if string
        country = Carmen::Country.all.find{ |c| no_accents(string).downcase.include?(no_accents(c.name.downcase)) }
        country.try(:name)
      end    end

    def find_region_strict(string, country)
      if string && country
        carmen_country = Carmen::Country.named(country)
        region = carmen_country.subregions.find{ |sr| no_accents(string.downcase).include?(no_accents(sr.name.downcase)) }
        region.try(:name)
      end    end

    def find_locality(string, country=nil)
      if string && country
        #swap out for FULL CITIES database stuff?
        Services::City.new.find_in(string)
      elsif string
        Services::City.new.find_in(string)
      end    end

    def scan_country_strict(string)
      if string
        test_string = de_tag( no_accents(string) )
        country_array = []
        Carmen::Country.all.each do |c|
          if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            name = c.name
            count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).length
            country_array << [name, count]
          end
        end
        return country_array.flatten
      end
    end

    def scan_region_strict(string, country=nil)
      # if string && country
      #   carmen_country = Carmen::Country.named(country)
      #   test_string = de_tag( no_accents(string) )
      #   region_array = []
      #   Carmen::Country.all.each do |c|
      #     if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
      #       name = c.name
      #       count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).length
      #       region_array << [name, count]
      #     end
      #   end
      #   return region_array.flatten
      # end
    end

    def scan_locality_strict(string, country=nil)
      # if string && country
      #   test_string = de_tag( no_accents(string) )
      #   carmen_country = Carmen::Country.named(country)
      #   locality_array = []
      #   Carmen::Country.all.each do |c|
      #     if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!)
      #       name = c.name
      #       count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!).length
      #       country_array << [name, count]
      #     end
      #   end
      #   return country_array.flatten
      # elsif string
      if string
        test_string = de_tag( no_accents(string).downcase )
        locality_array = []
        Services::City.new.cities.each do |c, hash|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{no_accents(c)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            name = hash[:accented]
            count = test_string.scan(%r!(?:\A|[ ]|\>)#{no_accents(c)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).length
            locality_array << [name, count]
          end
        end
        return locality_array.flatten
      end
    end

    def scan_country(string)
      if string
        test_string = de_tag( no_accents(string) )
        country_array = []
        Carmen::Country.all.each do |c|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            test_string.scan(%r!(?:\A|[ ]|\>)#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do
              country_array << c.name
            end
          end
        end
        return country_array.flatten
      end
    end

    def scan_region(string, country=nil)
      if string && country
        carmen_country = Carmen::Country.named(country)
        test_string = de_tag( no_accents(string) )
        region_array = []
        carmen_country.subregions.each do |c|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            test_string.scan(%r!(?:\A|[ ]|\>)#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do
              region_array << c.name
            end
          end
        end
        return region_array.flatten
      end
        region.try(:name)
    end

    def scan_locality(string, country=nil)
      if string
        test_string = de_tag( no_accents(string).downcase )
        locality_array = []
        Services::City.new.cities.each do |c, hash|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{no_accents(c)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            test_string.scan(%r!(?:\A|[ ]|\>)#{no_accents(c)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do 
              locality_array << hash[:accented]
            end
          end
        end
        return locality_array.flatten
      end
    end

    def find_country_by_locality(string)
      if string
        #swap out for FULL CITIES database stuff?
        Services::City.new.get_city_country(string)
      end    end

    def guess_sublocale(string_array, locale_array) # returns locality [0], region [1], country [2], full_string [3]
      if !string_array.is_a? Array
        string_array = [string_array]
      end
      string_array.each do |string|
        if locality = find_locality(string)
          return locality
        # elsif locale_array[1] && locale_array[1].length > 0
        #   region = locale_array[1]
        #   if locality = find_locality(string, region)
        #     return locality
        #   end 
        elsif locale_array[2] && locale_array[2].length > 0
          country = locale_array[2]
          if locality = find_locality(string, country)
            return locality
          elsif region = find_region_strict(string, country)
            return region
          end 
        end 
      end
      return nil    end

    def guess_locale(string_array) # returns "highest confidence" locality [0], region [1], country [2], full_string [3]
      
      if string_array.is_a? String
        string_array = [string_array]
      end

      if string_array.is_a? Array

        country_guess = []
        string_array.each do |string|
          country_guess << scan_country(string)
        end
        if country_guess
          country_guess = country_guess.flatten
          if country_guess.compact.uniq.length == 1
            country = country_guess.first

            region_guess = []
            string_array.each do |string|
              region_guess << scan_region(string, country)
            end
            if region_guess
              region_guess = region_guess.flatten
              if region_guess.compact.uniq.length == 1
                region = region_guess.first
              elsif region_guess && region_guess.compact.uniq.length > 1
                region = top_pick(region_guess)[0]
              else
                region = nil
              end
            end

          elsif country_guess && country_guess.compact.uniq.length > 1
            country = top_pick(country_guess)[0]
          else
            country = nil
            region = nil
          end
        end

        locality_guess = []
        string_array.each do |string|
          locality_guess << scan_locality(string)
        end
        if locality_guess
          locality_guess = locality_guess.flatten
          if locality_guess.compact.uniq.length == 1
            #does locality match country code of country if country? otherwise reject
            locality = locality_guess.first
          elsif locality_guess && locality_guess.compact.uniq.length > 1
            locality = top_pick(locality_guess)[0]
          else
            locality = nil
          end

          if locality && !country
            country = find_country_by_locality(locality.downcase)
          end
        end

        return [locality, region, country, [locality, region, country].compact.join(", ")]

      end
    end
    

    def guess_first_locale(string_array) # precise, first/single-answer per -- returns locality [0], region [1], country [2], full_string [3]
      
      country_guess = []

      if string_array.is_a? String
        string_array = [string_array]
      end

      if string_array.is_a? Array
        string_array.each do |string|
          country_guess << find_country(string)
        end
        if country_guess && country_guess.compact.uniq.length == 1
          country = country_guess.first

          region_guess = []
          string_array.each do |string|
            region_guess << find_region(string, country)
          end
          if region_guess && region_guess.compact.uniq.length == 1
            region = region_guess.first
          elsif region_guess && region_guess.compact.uniq.length > 1
            region = top_pick(region_guess)[0]
          else
            region = nil
          end
        elsif country_guess && country_guess.compact.uniq.length > 1
          country = top_pick(country_guess)[0]
        else
          country = nil
          region = nil
        end

        locality_guess = []
        string_array.each do |string|
          locality_guess << find_locality(string)
        end
        if locality_guess && locality_guess.compact.uniq.length == 1
          #does locality match country code of country if country? otherwise reject
          locality = locality_guess.first
        elsif locality_guess && locality_guess.compact.uniq.length > 1
          locality = top_pick(locality_guess)[0]
        else
          locality = nil
        end

        if locality && !country
          country = find_country_by_locality(locality.downcase)
        end

        return [locality, region, country, [locality, region, country].compact.join(", ")]

      end
    end

    def guess_locale_rough(string_array) # returns locality [0], region [1], country [2], full_string [3]
      guess_locale(string_array)
    end

    def trim_full_to_street_address(full_address, country=nil, postal_code=nil, region=nil, locality=nil, name=nil)
      if full_address
        street_address = full_address.gsub(/\A#{name}/, '') unless !name
        street_address = street_address.gsub(%r!((?:#{country}.*?)?)#{country}.*!, '\\1') unless !street_address || !country || country == ''
        street_address = street_address.gsub(%r!((?:#{postal_code}.*?)?)#{postal_code}.*!, '\\1') unless !street_address || !postal_code || postal_code == ''
        street_address = street_address.gsub(%r!((?:#{region}.*?)?)#{region}.*!, '\\1') unless !street_address || !region || region == ''
        street_address = street_address.gsub(%r!((?:#{locality}.*?)?)#{locality}.*!, '\\1') unless !street_address || !locality || locality == ''
        street_address = street_address.gsub(/([,-][ ]*)*\Z/, '') unless !street_address
        street_address = street_address.gsub(/,\s?\s?\s?\s?,/, ',') unless !street_address
        street_address = trim street_address unless !street_address
        street_address = nil unless trim(street_address) != ""
        return street_address
      end
    end

  end
end