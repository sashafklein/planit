module Scrapers
  class Foursquare < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if venue?(url)
        FoursquareMod::Venue.new(url, page)
      elsif item?(url)
        FoursquareMod::Item.new(url, page)
      elsif list?(url)
        FoursquareMod::List.new(url, page)
      end
    end

    def self.venue?(url)
      url.include?('/v/')
    end

    def self.item?(url)
      url.include?('/item/')
    end

    def self.list?(url)
      url.include?('/list/')
    end

  end
end