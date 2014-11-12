module Scrapers
  class Yelp < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        YelpMod::SingleItem.new(url, page)
      end
    end

    def self.single_item?(url)
      if url.include?("/biz/") && !url.split("/biz/")[1].blank?
        return true
      end
      return false
    end

  end
end