module Services
  class StreetAddress

    attr_accessor :full_address, :response
    include RegexLibrary

    def initialize(full_address, response=nil)
      @full_address, @response = full_address, response || Geocoder.search(full_address).first.try(:data)
    end

    def parse!
      trim_locality_type_content
      trim_neighborhood
      full_address
    end

    private

    def split_by(response_string, length)
      full_address.split(fetch_address_value(response_string, length))
    end

    def fetch_address_value(type, length='long_name')
      component = response['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end

    def trim_locality_type_content
      ['locality', 'administrative_area_level_2', 'administrative_area_level_1', 'postal_code', 'country'].each do |response_substring|
        ['long_name', 'short_name'].each do |length|
          if (split_array = split_by(response_substring, length) ).length <= 2
            @full_address = trim_comma_semicolon_space_start_finish( split_array.first )
          end
        end
      end
    end

    def trim_neighborhood
      ['neighborhood'].each do |response_substring|
        ['long_name', 'short_name'].each do |length|
          if (split_array = split_by(response_substring, length) ).length <= 2
            if split_array.last < 2
              @full_address = trim_comma_semicolon_space_start_finish( split_array.first )
            end
          end
        end
      end
    end

  end
end
