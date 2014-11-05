module Scrapers
  class Fodors < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if review?(url)
        FodorsMod::Review.new(url, page)
      # elsif thirty_six_new?(url)
      #   NytimesMod::SeparatedDetails.new(url, page)
      end
    end

    def self.review?(url)
      url.include?('/world/') && url.include?('/review-') 
    end

  end
end