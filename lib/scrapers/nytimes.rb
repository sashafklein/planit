module Scrapers
  class Nytimes < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if thirty_six_old?(url)
        NytimesMod::IncorporatedDetails.new(url, page)
      elsif thirty_six_new?(url)
        NytimesMod::SeparatedDetails.new(url, page)
      # elsif restaurant_new?(url)
      #   NytimesMod::RestaurantReview.new(url, page)
      # elsif restaurant_report?(url)
      #   NytimesMod::RestaurantReport.new(url, page)
      # elsif hotel_review?(url)
      #   NytimesMod::HotelReview.new(url, page)
      end
    end

    def self.thirty_six_old?(url)
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def self.thirty_six_new?(url)
      url.include?('things-to-do-in-36-hours')
    end

    # def self.restaurant_new?(url)
    #   url.include?('/dining/')
    # end

    # def self.restaurant_report?(url)
    #   url.include?('/travel/restaurant-report')
    # end

    # def self.hotel_review?(url)
    #   url.include?('/travel/hotel-review')
    # end

  end
end