module Scrapers
  class Nationalgeographic < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if favorite?(url)
        NationalgeographicMod::Favorites.new(url, page)
      end
    end

    def self.favorite?(url)
      if url.include?("/favorites/") && url.include?("/reviews/") && !url.split("/reviews/")[1].blank?
        return true
      end
      return false
    end

  end
end