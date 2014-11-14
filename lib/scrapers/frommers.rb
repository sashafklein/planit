module Scrapers
  class Frommers < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if destination?(url) && single_item?(url)
        FrommersMod::SingleItem.new(url, page)
      elsif destination?(url) && clean_list?(url, page)
        FrommersMod::CleanList.new(url, page) #side trips, overviews, itineraries
      elsif destination?(url)
        FrommersMod::Other.new(url, page) #side trips, overviews, itineraries
      end
    end

    def self.destination?(url)
      url.include?('/destinations/')
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'hotels',
        'restaurants',
        'attractions',
        'nightlife',
        'shopping',
      ]
      acceptable_single_items.any?{ |i| url.match(/\/#{i}\/.+/) }
    end

    def self.clean_list?(url, page)
      page = Nokogiri::HTML page
      if sortable_table = page.css(".table.sortable").first
        if sortable_table.css("tr").length > 2
          return true
        end
      end
      return false
    end
  end
end