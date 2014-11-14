module Scrapers
  class Huffingtonpost < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if article?(page)
        HuffingtonpostMod::Article.new(url, page)
      # elsif travel_separate_2012?(url, page)
      #   HuffingtonpostMod::GeneralTravel.new(url, page)
      end
    end

    def self.article?(page)
      page = Nokogiri::HTML page
      if section_header = page.css(".title.travel").first
        if section_header.text.include?("Travel")
          return true
        end
      end
      return false
      # url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

  end
end