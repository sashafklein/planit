module Services
  module GeoQueries

    include TrimFunctions
    include ScraperOperators

    # FIND SINGLE LOCATION

    def find_country(string)
      if string.present?
        country = Carmen::Country.all.find{ |c| string.no_accents.downcase.include?(c.name.downcase.no_accents) }
        country ||= Carmen::Country.all.find{ |c| (string).include?("#{c.alpha_3_code.titleize}.") } 
        country ||= Carmen::Country.all.find{ |c| (string).include?(c.alpha_3_code.upcase) } 
        country.try(:name)
      end
    end

    def find_country_by_code(string)
      if string.present?
        country ||= Carmen::Country.all.find{ |c| (string.upcase).include?(c.code.upcase) } 
        country.try(:name)
      end
    end

    def find_country_by_locality(string)
      if string.present?
        #swap out for FULL CITIES database stuff?
        Directories::City.new.get_city_country(string)
      end
    end

    def find_country_strict(string)
      if string.present?
        country = Carmen::Country.all.find{ |c| string.no_accents.downcase.include?(c.name.downcase.no_accents) }
        country.try(:name)
      end
    end

    def find_region(string, country)
      if string.present? && country.present?
        carmen_country = Carmen::Country.named(country)
        if carmen_country
          region = carmen_country.subregions.find{ |sr| string.downcase.no_accents.include?(sr.name.downcase.no_accents) }
          region ||= carmen_country.subregions.find{ |sr| string.no_accents.include?("#{sr.name.no_accents.first(3)}.") }
          region ||= carmen_country.subregions.find{ |sr| string.match(/[,]\s?#{sr.code.upcase}/) }
          return region.try(:name)
        end
      end
      return nil
    end

    def find_region_strict(string, country)
      if string.present? && country.present?
        carmen_country = Carmen::Country.named(country)
        if carmen_country
          region = carmen_country.subregions.find{ |sr| string.downcase.no_accents.include?(sr.name.downcase.no_accents) }
          return region.try(:name)
        end
      end
      return nil
    end

    def find_locality(string, country=nil)
      if string.present?
        cluster = Directories::City.new.find_accented_in(string)
        cluster ? cluster.last[:accented] : nil
      end
    end

    # SCAN FOR MULTIPLE LOCATIONS

    def scan_country_strict(string)
      if string.present?
        test_string = de_tag( string.no_accents )
        country_array = []
        Carmen::Country.all.each do |c|
          if match = test_string.match(%r!#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            name = c.name
            count = test_string.scan(%r!#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).length
            country_array << [name, count]
          end
        end
        return country_array.flatten
      end
    end

    def scan_locality_strict(string, country=nil)
      if string.present?
        test_string = de_tag( string.no_accents.downcase )
        locality_array = []
        Directories::City.new.cities.each do |c, hash|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{c.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            name = hash[:accented]
            count = test_string.scan(%r!(?:\A|[ ]|\>)#{c.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).length
            locality_array << [name, count]
          end
        end
        return locality_array.flatten
      end
    end

    def scan_country(string)
      if string.present?
        test_string = de_tag( string.no_accents )
        country_array = []
        Carmen::Country.all.each do |c|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            test_string.scan(%r!(?:\A|[ ]|\>)#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do
              country_array << c.name
            end
          end
        end
        return country_array.flatten
      end
    end

    def scan_region(string, country=nil)
      if string.present? && country.present?
        carmen_country = Carmen::Country.named(country)
        test_string = de_tag( string.no_accents )
        region_array = []
        if carmen_country
          carmen_country.subregions.each do |c|
            if match = test_string.match(%r!(?:\A|[ ]|\>)#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
              test_string.scan(%r!(?:\A|[ ]|\>)#{c.name.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do
                region_array << c.name
              end
            end
          end
        end
        return region_array.flatten
      end
    end

    def scan_locality(string, country=nil)
      if string.present?
        test_string = de_tag( string.no_accents.downcase )
        locality_array = []
        Directories::City.new.cities.each do |c, hash|
          if match = test_string.match(%r!(?:\A|[ ]|\>)#{c.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!)
            test_string.scan(%r!(?:\A|[ ]|\>)#{c.no_accents}(?:['’]s)?(?:\Z|[ ]|[,]|[;]|[.]|[:]|[)]|[\/]|[\\])!).each do 
              locality_array << hash[:accented]
            end
          end
        end
        return locality_array.flatten
      end
    end

    # GUESS LOCALES

    def guess_sublocale(string_array, guess_locale_hash)
      string_array = [string_array] if !string_array.is_a? Array
      if string_array.is_a? Array
        locality_alone = string_array.map{ |string| find_locality(string) }.flatten.compact
        return locality_alone.first if locality_alone.uniq.count == 1
        if country = guess_locale_hash[:country] && country.present?
          locality_via_country = string_array.map{ |string| find_locality(string, country) }.flatten.compact
          return locality_via_country.first if locality_via_country.uniq.count == 1
          region_via_country = string_array.map{ |string| find_region(string, country) }.flatten.compact
          return region_via_country.first if region_via_country.uniq.count == 1
        end
      end
      return nil
    end

    def guess_locale(string_array, rough=false) # returns "highest confidence" locality, region & country
      if string_array.present?
        string_array = [string_array] if string_array.is_a? String

        locality_guesses = string_array.map{ |string| scan_locality(string) }.flatten.compact 
        locality = locality_guesses.first if locality_guesses.uniq.length == 1
        locality ||= top_pick(locality_guesses)[:is]
        locality ||= nil

        country_guesses = string_array.map{ |string| scan_country(string) }.flatten.compact
        country = country_guesses.first if country_guesses.uniq.length == 1
        country ||= top_pick(country_guesses)[:is]
        country ||= find_country_by_locality(locality.downcase) if locality
        country ||= nil

        region_guesses = string_array.map{ |string| scan_region( string, country ) }.flatten.compact if country
        region = region_guesses.first if country && region_guesses.uniq.length == 1
        region ||= top_pick(region_guesses)[:is] if country                
        region ||= nil

        { locality: locality, region: region, country: country }

      end
    end
    
    def guess_locale_rough(string_array) # ideally what differentiates this?
      guess_locale(string_array, true)
    end

    # TRIM ADDRESSES DOWN

    def trim_full_to_street_address(full_address:, country: nil, postal_code: nil, region: nil, locality: nil, name: nil)
      if full_address.present?
        in_edit = full_address.gsub(/\A#{name}/, '') unless !name
        in_edit = in_edit.gsub(%r!((?:#{country}.*?)?)#{country}.*!, '\\1') unless !in_edit || !country.present?
        in_edit = in_edit.gsub(%r!((?:#{postal_code}.*?)?)#{postal_code}.*!, '\\1') unless !in_edit || !postal_code.present?
        in_edit = in_edit.gsub(%r!((?:#{region}.*?)?)#{region}.*!, '\\1') unless !in_edit || !region.present?
        in_edit = in_edit.gsub(%r!((?:#{locality}.*?)?)#{locality}.*!, '\\1') unless !in_edit || !locality.present?
        in_edit = in_edit.gsub(/([,-][ ]*)*\Z/, '') unless !in_edit
        in_edit = in_edit.gsub(/,\s?\s?\s?\s?,/, ',') unless !in_edit
        street_address = trim in_edit
      end
    end

    def pseudo_nearby(full_address)
      if full_address.present?
        n = full_address.split(",")
        n.shift
        n.join(", ")
          .scan(/\A[-0-9,\. ]*(.*?)\Z/)
          .flatten.first 
      end
    end

  end
end