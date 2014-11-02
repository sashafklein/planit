module Scrapers
  class Tripadvisor < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if single_item?(url)
        TripadvisorMod::ItemReview.new(url, page)
      # elsif thirty_six_new?(url)
      #   TripadvisorMod::SeparatedDetails.new(url, page)
      # elsif restaurant_new?(url)
      #   TripadvisorMod::RestaurantReview.new(url, page)
      # elsif restaurant_report?(url)
      #   TripadvisorMod::RestaurantReport.new(url, page)
      # elsif hotel_review?(url)
      #   TripadvisorMod::HotelReview.new(url, page)
      end
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'Attraction_Review',
        'Hotel_Review',
        'VacationRentalReview',
        'Restaurant_Review',
      ]
      acceptable_single_items.each do |accept|
        if url.include?("/#{accept}-")
          return true
        end
      end
      return false
    end

    # def self.reviews_item?(url)
    #   acceptable_reviews_items = [
    #     'ShowUserReviews',
    #   ]
    #   url.include?("/#{acceptable_reviews_items.any?}-")
    # end
    # def self.thirty_six_new?(url)
    #   url.include?('things-to-do-in-36-hours')
    # end

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
