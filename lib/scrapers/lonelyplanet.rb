module Scrapers
  class Lonelyplanet < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        LonelyplanetMod::SingleItem.new(url, page)
      # elsif thirty_six_new?(url)
      #   NytimesMod::SeparatedDetails.new(url, page)
      end
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'entertainment-nightlife',
        'restaurants',
        'hotels',
        'sights',
      ]
      acceptable_single_items.each do |accept|
        if url.include?("/#{accept}/")
          return true
        end
      end
      return false
    end

    def self.tour_or_activity?(url)
      acceptable_single_items = [
        'activities',
        'tours',
      ]
      acceptable_single_items.each do |accept|
        if url.include?("/#{accept}/")
          return true
        end
      end
      return false
    end

  end
end