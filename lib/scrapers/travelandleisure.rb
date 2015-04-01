module Scrapers
  class Travelandleisure < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        TravelandleisureMod::SingleItem.new(url, page)
      # elsif trip?(url)
      #   TravelandleisureMod::Trip.new(url, page)
      # elsif article?(url) && contains_sidebar?(page)
      #   TravelandleisureMod::Article.new(url, page)
      end
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'restaurants',
        'hotels',
        'activities',
      ]
      acceptable_single_items.each do |accept|
        if url.include?("/#{accept}/") && url.include?("/travel-guide/")
          return true
        end
      end
      return false
    end

    def self.trip?(url)
      if url.include?("/trips/") && url.include?("/trip-guide-")
        return true
      end
      return false
    end

    def self.article?(url)
      if url.include?("/articles/")
        return true
      end
      return false
    end

    def self.contains_sidebar?(page)
      page = Nokogiri::HTML page
      if wrapper = page.css(".sidebar-content-wrapper")
        if header = wrapper.css("h2.hed:contains('Guide to')")
          if !wrapper.css("content").empty?
            return true
          end
        end
      end
      return false
    end

  end
end