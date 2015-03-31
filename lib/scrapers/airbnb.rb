module Scrapers
  class Airbnb < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if itinerary?(url)
        AirbnbMod::Itinerary.new(url, page)
      elsif browse?(url)
        AirbnbMod::Browse.new(url, page)
      elsif reservation_receipt?(url)
        AirbnbMod::ReservationReceipt.new(url, page)
      end
    end

    def self.itinerary?(url)
      url.include?('/reservation/itinerary?code=')
    end

    def self.browse?(url)
      url.include?('/rooms/')
    end

    def self.reservation_receipt?(url)
      url.include?('/reservation/receipt')
    end

  end
end