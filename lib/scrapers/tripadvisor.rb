module Scrapers
  class Tripadvisor < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if travelmap?(url)
        TripadvisorMod::Travelmap.new(url, page)
      elsif single_item?(url)
        TripadvisorMod::ItemReview.new(url, page)
      elsif reviews_item?(url)
        TripadvisorMod::UserReviews.new(url, page)
      elsif guide?(url)
        TripadvisorMod::Guide.new(url, page)
      end
    end

    def self.travelmap?(url)
      if url.include?("/TravelMapHome")
        return true
      end
    end

    def self.single_item?(url)
      acceptable_single_items = [
        'Attraction_Review',
        'Hotel_Review',
        'VacationRentalReview',
        'Restaurant_Review',
      ]
      acceptable_single_items.any?{ |i| url.include?("/#{i}-") }
    end

    def self.reviews_item?(url)
      acceptable_reviews_items = [
        'ShowUserReviews',
      ]
      acceptable_reviews_items.each do |accept|
        if url.include?("/#{accept}-")
          return true
        end
      end
      return false
    end

    def self.guide?(url)
      acceptable_reviews_items = [
        'Guide',
      ]
      acceptable_reviews_items.each do |accept|
        if url.include?("/#{accept}-")
          return true
        end
      end
      return false
    end

  end
end
