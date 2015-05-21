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
      # elsif google_map_enabled?(url, page)
      #   NytimesMod::GoogleMapped.new(url, page)
      elsif thirty_six_new?(url)
        NytimesMod::SeparatedThirtySixDetails.new(url, page)
      elsif restaurant_new?(url)
        NytimesMod::RestaurantReview.new(url, page)
      # elsif restaurant_report?(url)
      #   NytimesMod::RestaurantReport.new(url, page)
      # elsif hotel_review?(url)
      #  NytimesMod::HotelReview.new(url, page)
      elsif only_fake_map?(url, page)
        NytimesMod::FakeMap.new(url, page)
      elsif travel?(url)
        NytimesMod::GeneralTravel.new(url, page)
      end
    end

    def self.thirty_six_old?(url)
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def self.thirty_six_new?(url)
      url.include?('to-do-in-36-hours') && url.include?('/travel/')
    end

    def self.google_map_enabled?(url, page)
      page = Nokogiri::HTML page
      find_scripts_inner_html(page).each do |script|
        if script.flatten.first.scan(nytimes_map_data_regex).length > 0
          return true
        end
      end
      return false
    end

    def self.only_fake_map?(url, page)
      page = Nokogiri::HTML page
      if interactive_graphic = page.css(".interactive-graphic").first
        if fake_map = page.css(".interactive-graphic").inner_html.match(/['"].*PERSONALmap.*['"]/)
          page.css(".interactive-graphic").each do |test_text|
            if test_text.css("p").text || test_text.css(".g-aiAbs").text
              return true 
            end
          end
        end
      end
      return false
    rescue ; nil
    end

    def self.what_is_this?(url, page)
      page = Nokogiri::HTML page
      # if wrapper = page.css(".articleBody")
      #   ["downcase", "titleize", "upcase", "capitalize"].each do |operator|
      #     search_term = "if you go".send(operator)
      #     if separation = wrapper.css("strong:contains('#{search_term}')").first
      #       if separation.parent.next_element.present?
      #         return true
      #       end
      #     end
      #   end
      # end
      return false
    end

    def self.restaurant_new?(url)
      url.include?('/dining/')
    end

    def self.travel?(url)
      url.include?('/travel/')
    end

    def self.restaurant_report?(url)
      url.include?('/travel/restaurant-report')
    end

    def self.hotel_review?(url)
      url.include?('/travel/hotel-review')
    end

    private

    def wrapper
      return unless @scrape_target
      @scrape_target.each do |try_wrapper|
        return page.css(try_wrapper) if page.css(try_wrapper).first
      end
    end
  end
end