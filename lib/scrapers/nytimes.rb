module Scrapers
  class Nytimes < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if no_detail_box?(url)
        Nyt::IncorporatedDetails.new(url, page)
      elsif has_detail_box?(url)
        Nyt::SeparatedDetails.new(url, page)
      end
    end

    def self.no_detail_box?(url)
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def self.has_detail_box?(url)
      url.include?('things-to-do-in-36-hours')
    end

  end
end