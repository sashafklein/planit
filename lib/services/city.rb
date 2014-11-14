module Services
  class City
    attr_accessor :country_code

    def initialize(country_code='top')
      @country_code = country_code.downcase
    end

    def find_in(string)
      city = cities.find do |name, accented|
        string.downcase.match /(?:\A|[ ]|[,]|[;]|[.])#{name}(?:\z|[ ]|[,]|[;]|[.])/
      end
      city ? city.last[:accented] : nil
    end

    def get_city_country(city)
      city = cities.find do |name, country|
        city.downcase.match /#{name}/
      end
      city ? city.last[:country] : nil
    end

    private

    def cities
      @file ||= YAML.load File.read( File.join(Rails.root, 'lib', 'cities', "#{country_code}.yml"))
    end
  end
end 