module Services
  module GeoQueries
    
    def find_country(string)
      if string
        country = Carmen::Country.all.find{ |c| no_accents(string).downcase.include?(no_accents(c.name.downcase)) }
        country ||= Carmen::Country.all.find{ |c| (string).include?("#{c.alpha_3_code.titleize}.") } 
        country ||= Carmen::Country.all.find{ |c| (string).include?(c.alpha_3_code.upcase) } 
        country.try(:name)
      end
    rescue ; nil
    end

    def find_region(string, country)
      if string && country
        carmen_country = Carmen::Country.named(country)
        region = carmen_country.subregions.find{ |sr| no_accents(string.downcase).include?(no_accents(sr.name.downcase)) }
        region ||= carmen_country.subregions.find{ |sr| no_accents(string).include?("#{no_accents(sr.name).first(3)}.") }
        region ||= carmen_country.subregions.find{ |sr| string.include?(sr.code.upcase) }
        region.try(:name)
      end
    rescue ; nil
    end

    def find_country_strict(string)
      if string
        country = Carmen::Country.all.find{ |c| no_accents(string).downcase.include?(no_accents(c.name.downcase)) }
        country.try(:name)
      end
    rescue ; nil
    end

    def find_region_strict(string, country)
      if string && country
        carmen_country = Carmen::Country.named(country)
        region = carmen_country.subregions.find{ |sr| no_accents(string.downcase).include?(no_accents(sr.name.downcase)) }
        region.try(:name)
      end
    rescue ; nil
    end

    def find_locality(string, country=nil)
      if string && country
        #swap out for FULL CITIES database stuff?
        Services::City.new.find_in(string)
      elsif string
        Services::City.new.find_in(string)
      end
    rescue ; nil
    end

    def scan_country_strict(string)
      if string
        test_string = de_tag( no_accents(string) )
        country_array = []
        Carmen::Country.all.each do |c|
          if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!)
            name = c.name
            count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!).length
            country_array << [name, count]
          end
        end
        return country_array.flatten
      end
    end

    # def scan_region_strict(string, country=nil)
    #   if string && country
    #     carmen_country = Carmen::Country.named(country)
    #     test_string = de_tag( no_accents(string) )
    #     region_array = []
    #     Carmen::Country.all.each do |c|
    #       if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!)
    #         name = c.name
    #         count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!).length
    #         region_array << [name, count]
    #       end
    #     end
    #     return country_array.flatten
    #   end
    # end

    # def scan_locality_strict(string, country=nil)
    #   if string && country
    #     test_string = de_tag( no_accents(string) )
    #     carmen_country = Carmen::Country.named(country)
    #     country_array = []
    #     Carmen::Country.all.each do |c|
    #       if match = test_string.match(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!)
    #         name = c.name
    #         count = test_string.scan(%r!#{no_accents(c.name)}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.])!).length
    #         country_array << [name, count]
    #       end
    #     end
    #     return country_array.flatten
    #   elsif string

    #   end
    # end

    def find_country_by_locality(string)
      if string
        #swap out for FULL CITIES database stuff?
        Services::City.new.get_city_country(string)
      end
    rescue ; nil
    end

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
      return nil
    # rescue ; nil
    end

    def guess_locale(string_array) # precise, single-answer per -- returns locality [0], region [1], country [2], full_string [3]
      
      country_guess = []

      if string_array.is_a? String
        string_array = [string_array]
      end

      if string_array.is_a? Array
        string_array.each do |string|
          country_guess << find_country(string)
        end
        if country_guess && country_guess.uniq.length == 1
          country = country_guess.first
          region_guess = []
          string_array.each do |string|
            country_guess << find_region(string, country)
          end
          if region_guess && region_guess.uniq.length == 1
            region = region_guess.first
          end
        end

        locality_guess = []
        string_array.each do |string|
          locality_guess << find_locality(string)
        end
        if locality_guess && locality_guess.uniq.length == 1
          #does locality match country code of country if country? otherwise reject
          locality = locality_guess.first
        end

        if locality && !country
          country = find_country_by_locality(locality.downcase)
        end

        return [locality, region, country, [locality, region, country].compact.join(", ")]

      end

    rescue ; nil
    end
    
    def guess_locale_rough(string_array) # returns locality [0], region [1], country [2], full_string [3]
      guess_locale(string_array)
    end

  end
end