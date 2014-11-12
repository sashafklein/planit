module Scrapers
  class Stay < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        StayMod::ItemReview.new(url, page)
      elsif highlight?(page) || guide?(url)
        StayMod::Highlight.new(url, page)
      elsif neighborhood?(url)
        StayMod::Neighborhood.new(url, page)
      end
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'attractions',
        'museum',
        'art-gallery',
        'shopping',
        'health',
        'entertainment',
        'cafe',
        'bar-pub',
        'nightclub',
        'restaurant',
        'hotel',
      ]
      acceptable_single_items.each do |accept|
        if url.include?("/#{accept}/") && !url.split("/#{accept}/")[1].blank?
          return true
        end
      end
      return false
    end

    def self.guide?(url)
      acceptable_reviews_items = [
        'guides',
      ]
      acceptable_reviews_items.each do |accept|
        if url.include?("/#{accept}/") && !url.split("/#{accept}/")[1].blank?
          return true
        end
      end
      return false
    end

    def self.neighborhood?(url)
      acceptable_reviews_items = [
        'neighborhood',
      ]
      acceptable_reviews_items.each do |accept|
        if url.include?("/#{accept}/") && !url.split("/#{accept}/")[1].blank?
          return true
        end
      end
      return false
    end

    def self.highlight?(page)
      page = Nokogiri::HTML page
      if widget = page.css(".widget-section-selector").first
        if active = widget.css("li.active:contains('Highlights')").first
          return true 
        end
      end
      return false
    end

  end
end
