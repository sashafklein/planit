module Scrapers
  class Foursquare < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if venue?(url)
        FoursquareMod::Venue.new(url, page)
      elsif single_item?(url)
        FoursquareMod::SingleItem.new(url, page)
      elsif list?(url)
        FoursquareMod::List.new(url, page)
      end
    end

    def self.venue?(url)
      url.include?('/v/')
    end

    def self.single_item?(url)
      url.include?('/item/')
    end

    def self.list?(url)
      url.include?('/list/')
    end

    # NO-ERROR FUNCTIONS

    def safe_categories(categories)
      if categories.is_a? Object
        categories.map{ |c| c.name }
      end
    end

    def safe_phones(phones)
      if phones.is_a? Object
        phones.select{ |k,v| k == 'phone' }.map{ |k,v| v }
      end
    end

  end
end