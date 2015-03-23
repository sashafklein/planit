module PlaceMod
  class FeatureType

    attr_accessor :place, :value, :names, :nearby

    def initialize(place, nearby=nil)
      @place, @nearby = place, nearby.to_s.downcase.no_accents.without_common_symbols
      @names = place.names.compact.map(&:no_accents).map(&:without_common_symbols).map(&:downcase)
    end

    def determine
      lowest( names.map { |name| determine_genre_of_name(name) } )
    end

    def number
      Place.feature_types[ determine.try(:downcase) || 0 ]
    end

    private

    def determine_genre_of_name(name)
      category_result = includes_destination_category?( name )

      return category_result if category_result
      updated, found = name.dup, {}

      [:sublocality, :locality, :subregion, :region, :country].each do |type|
        if updated.strip.present? && finder = find(type, updated, found)
          updated = finder.remaining
          found[type] = finder.value
        end
      end

      if nearby.present? && name.include?(nearby)
        found[:area] ||= "Area"
        updated = updated.split(" ").reject{ |w| nearby.include?(w) }.join(" ")
      end

      return "Destination" unless updated.strip.blank?
      
      lowest(found.keys.map(&:to_s).map(&:capitalize)) || "Destination"
    end

    def find(type, name, found)
      send("find_#{type}", name, found)
    end

    def find_sublocality(name, found)
      finder_return( place.sublocality, name ) if place.sublocality && name.include?( place.sublocality.downcase )
    end

    def find_locality(name, found)
      if place.locality && name.include?( place.locality.downcase )
        finder_return place.locality, name
      elsif cluster = cities.find_in(name)
        finder_return cluster.first, name
      end
    end

    def find_subregion(name, found)
      finder_return( place.subregion, name ) if place.subregion && name.include?( place.subregion.downcase )
    end

    def find_region(name, found)
      finder_return( place.region, name ) if place.region && name.include?( place.region.downcase )
    end

    def find_country(name, found)
      if place.country && name.include?( place.country )
        finder_return place.country, name 
      else 
        if found[:locality]
          if name.include?( country = city_list[ found[:locality].downcase ][:country].downcase )
            return finder_return country, name
          end
        end
        if country = carmen_find_country(name)
          finder_return country, name
        end
      end
    end

    def finder_return(att, name)
      { remaining: name.gsub(att.downcase, ''), value: att }.to_sh
    end

    def find_area(name, found)
      finder_return( nearby.to_s, name ) if name.include?(nearby.to_s.no_accents.without_common_symbols)
    end

    def category_set
      @category_set ||= Directories::Categories.new.list
    end

    def includes_destination_category?(name, take_area=false)
      category_set.select{ |k, v| (k == 'area') == take_area }.each do |type, list| 
        list.each do |category|
          if name.downcase.scan( separated_regex(category) ).any?
            return ( take_area ? 'Area' : "Destination" ) 
          end
        end
      end
      nil
    end

    def lowest(values)
      %w( Destination Sublocality Locality Region Country Area ).find do |type|
        values.include?(type)
      end
    end

    def cities
      @cities ||= Directories::City.new
    end

    def city_list
      @city_list ||= cities.cities
    end

    def carmen_countries
      @carmen_countries ||= Carmen::Country.all
    end

    def carmen_find_country(name)
      carmen_countries.each do |country|
        [:name, :common_name, :code, :alpha_3_code].each do |spelling|
          finder = country.send(spelling)
          return finder if finder.present? && name.scan( separated_regex(finder) ).any?
        end
      end
      nil
    end

    def separated_regex(string)
      /(?:\s|^)#{ string.downcase }(?:\s|\z)/
    end
  end
end