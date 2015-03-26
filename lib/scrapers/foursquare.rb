module Scrapers
  class Foursquare < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single?(url)
        FoursquareMod::Single.new(url, page)
      end
    end

    def self.single?(url)
      url.include?('/v/')
    end

  end
end