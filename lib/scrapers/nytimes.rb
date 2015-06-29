module Scrapers
  class Nytimes < Services::SiteScraper

    extend Memoist
    
    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      scraper_class(url, page) ? scraper_class(url, page).new( url, page ) : nil
    end

    def self.scraper_class(url, page)
      return nil unless url.include?('/travel/')

      return NytimesMod::IncorporatedThirtySixDetails if url_include?( url: url, any: ['journeys-36-hours', 'hours.html'] )
      return NytimesMod::GoogleThirtySixMapped if google_map_enabled?(url, page)
      return NytimesMod::SeparatedThirtySixDetails if url_include?( url: url, all: ['to-do-in-36-hours'] )
      return NytimesMod::FakeMap if only_fake_map?(url, page)
      return NytimesMod::GeneralTravel
      # elsif google_map_enabled?(url, page)
      #   NytimesMod::GoogleMapped.new(url, page)
      # elsif restaurant_new?(url)
      #   NytimesMod::RestaurantReview.new(url, page)
      # elsif restaurant_report?(url)
      #   NytimesMod::RestaurantReport.new(url, page)
      # elsif hotel_review?(url)
      #  NytimesMod::HotelReview.new(url, page)
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

    def for_group_array(activities)
      activities.map do |activity|
        unless !trim( de_tag( activity ) ) || trim( de_tag( activity ) ).empty?
          [activity, @currently_in]
        end
      end.compact
    end

    def iterate_casing(string)
      [string.downcase, string.upcase, string.capitalize]
    end

    def tag_with_contents(tags:, contents:, section: wrapper)
      tags.each do |t| 
        found = section.css(t).find{ |e| contents.include?(e.inner_html) }
        return found if found
      end
      nil
    end

    def collect_between(first, last)
      first == last ? [first] : [first, *collect_between(first.next, last)]
    rescue
      [first]
    end

    def self.url_include?(url:, all: [], any: [])
      all.all?{ |s| url.include?(s) } && ( any.empty? || any.any?{ |s| url.include?(s) } )
    end

    def clean_note(note)
      return unless note
      note.gsub("’", "\'").gsub(/(?:^'|'$|^"|"$)/, '').gsub(/(?:\n+\s+)/, ' ').no_accents
    end
  end
end