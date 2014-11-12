module Scrapers
  class Eater < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if venue?(url)
        EaterMod::Venue.new(url, page)
      elsif heatmap?(url) || bestmap?(url)
        EaterMod::Heatmap.new(url, page)
      elsif review?(page)
        EaterMod::Review.new(url, page)
      end
    end

    def self.venue?(url)
      if url.include?("/venue/") && !url.split("/venue/")[1].blank?
        return true
      end
      return false
    end

    def self.heatmap?(url)
      if url.include?("/maps/") && url.include?("heatmap-where-to-eat") && !url.split("heatmap-where-to-eat")[1].blank?
        return true
      end
      return false
    end

    def self.bestmap?(url)
      if url.include?("/maps/") && url.include?("best-restaurants") && !url.split("best-restaurants")[1].blank?
        return true
      end
      return false
    end

    def self.review?(page)
      if page.include?("m-review-scratch__head")
        return true
      end
      return false
    end

  end
end