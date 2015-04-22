module Directories
  class City < Directories::BaseDirectory
    attr_accessor :country_code

    include RegexLibrary

    def initialize(country_code='top')
      @country_code = country_code.downcase
    end

    def find_in(string)
      city = cities.find do |name, hash|
        unless string.match(%r!\A#{is_website_link?}!)
          string.downcase.match /(?:\A|[ ]|[,]|[;]|[.]|[:]|[()]|[\/]|[\\])#{ name }(?:\z|[ ]|[,]|[:]|[;]|[.]|[)]|[\/]|[\\])/
        end
      end
      city
    end

    def find_accented_in(string)
      city = cities.find do |name, hash|
        unless string.match(%r!\A#{is_website_link?}!)
          string.downcase.match /(?:\A|[ ]|[,]|[;]|[.]|[:]|[()]|[\/]|[\\])(?:#{ hash[:no_accent].downcase }|#{ hash[:accented].downcase })(?:\z|[ ]|[,]|[:]|[;]|[.]|[)]|[\/]|[\\])/
        end
      end
      city
    end

    def get_city_country(city)
      city = cities.find do |name, hash|
        city.downcase.match /(?:#{name}|#{hash[:no_accent].downcase}|#{hash[:accented].downcase})/
      end
      city ? city.last[:country] : nil
    end

    def cities
      @file ||= YAML.load file('yml')
    end

  end
end 