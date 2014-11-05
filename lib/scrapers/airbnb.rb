module Scrapers
  class Airbnb < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if itinerary?(url)
        AirbnbMod::Itinerary.new(url, page)
      elsif browse?(url)
        AirbnbMod::Browse.new(url, page)
      end
    end

    def self.itinerary?(url)
      url.include?('/reservation/itinerary?code=')
    end

    def self.browse?(url)
      url.include?('/rooms/')
    end

  end
end