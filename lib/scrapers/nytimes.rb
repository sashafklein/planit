module Scrapers
  class Nytimes < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if thirty_six_old?(url)
        NytimesMod::IncorporatedThirtySixDetails.new(url, page)
      elsif thirty_six_new?(url) && google_map_enabled?(url, page)
        NytimesMod::GoogleThirtySixMapped.new(url, page)
      elsif google_map_enabled?(url, page)
        NytimesMod::GoogleMapped.new(url, page)
      elsif thirty_six_new?(url)
        NytimesMod::SeparatedThirtySixDetails.new(url, page)
      # elsif restaurant_new?(url)
      #   NytimesMod::RestaurantReview.new(url, page)
      # elsif restaurant_report?(url)
      #   NytimesMod::RestaurantReport.new(url, page)
      # elsif hotel_review?(url)
      #  NytimesMod::HotelReview.new(url, page)
      elsif travel_separate_2012?(url, page)
        NytimesMod::GeneralTravel.new(url, page)
      end
    end

    def self.thirty_six_old?(url)
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def self.thirty_six_new?(url)
      url.include?('things-to-do-in-36-hours')
    end

    def self.google_map_enabled?(url, page)
      page = Nokogiri::HTML page
      if url.include?('/travel/')
        for script in find_scripts_inner_html(page)
          if script.flatten.first.scan(nytimes_map_data_regex).length > 0
            return true
          end
        end
      end
      return false
    end

    def self.travel_separate_2012?(url, page)
      page = Nokogiri::HTML page
      if url.include?('/travel/')
        if wrapper = page.css(".articleBody")
          ["downcase", "titleize", "upcase", "capitalize"].each do |operator|
            search_term = "if you go".send(operator)
            if separation = wrapper.css("strong:contains('#{search_term}')").first
              if separation.parent.next_element.present?
                return true
              end
            end
          end
        end
      end
      return false
    end

    def self.restaurant_new?(url)
      url.include?('/dining/')
    end

    def self.restaurant_report?(url)
      url.include?('/travel/restaurant-report')
    end

    def self.hotel_review?(url)
      url.include?('/travel/hotel-review')
    end

  end
end