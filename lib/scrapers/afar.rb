module Scrapers
  class Afar < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        AfarMod::SingleItem.new(url, page)
      # elsif trip?(url)
      #   AfarMod::Trip.new(url, page)
      # elsif article?(url) && contains_sidebar?(page)
      #   AfarMod::Article.new(url, page)
      end
    end

    def self.single_item?(url)
      if url.include?("/places/") && !url.split("/places/")[1].blank?
        return true
      end
      return false
    end

  end
end