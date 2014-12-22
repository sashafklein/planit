module Scrapers
  class Googlemaps < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      GooglemapsMod::Starred.new(url, page)
    end

  end
end