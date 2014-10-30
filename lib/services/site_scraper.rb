module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    include RegexLibrary
    include CssOperators

    def self.build(url, page)
      specific_scraper(url, page)
    end

    attr_accessor :url, :page
    delegate :css, to: :page
    def initialize(url, page)
      @url = url
      @page = Nokogiri::HTML page
      @data = []
    end

    # PAGE FLOW

    def data
      return @data if @data.length > 0

      itinerary_group.each_with_index do |itinerary, itinerary_index|
        leg_group(itinerary).each_with_index do |leg, leg_index|
          day_group(leg).each_with_index do |day, day_index|
            section_group(day).each_with_index do |section, section_index|
              activity_group(section).each_with_index do |activity, activity_index|
                item = full_item([
                  activity_data(activity, activity_index), 
                  section_data(section, section_index), 
                  day_data(day, day_index), 
                  leg_data(leg, leg_index), 
                  itinerary_data(itinerary, itinerary_index), 
                  global_data
                ])
                @data << item
              end
            end
          end
        end
      end

      general_group.each_with_index do |general, general_index|
        @data << full_item([general_data(general, general_index)])
      end
      @data
    end

    private

    def self.specific_scraper(url, page)
      class_name = URI(url).host.match(/[^\.]+\.\w+$/).to_s.split('.').first.capitalize
      scraper = "Scrapers::#{class_name}".constantize
      scraper.build(url, page)
    end

    # FLOW DEFAULTS

    def itinerary_group;                            [leg_group(nil)];   end
    def itinerary_data(itinerary, itinerary_index); {};                 end
    def leg_group(itinerary);                       [day_group(nil)];   end
    def leg_data(leg, leg_index);                   {};                 end
    def day_group(leg);                             [section_group];    end
    def day_data(day, day_index);                   {};                 end
    def section_group(day);                         [activity_group];   end
    def section_data(section, section_index);       {};                 end
    def activity_group(section);                    [];                 end
    def activity_data(activity, activity_index);    {};                 end

    def full_item(datas_array)
      progressive_merge(datas_array)
    end

    def progressive_merge(array_of_hashes)
      array_of_hashes.inject({}) { |f, h| f.merge(h) }
    end

    # OPERATIONS
    
    def scrape_container(list)
      return @scrape_container if @scrape_container
      selector = list.select{ |sel| css(sel).any? }.first
      @scrape_container = css(selector) if selector
    end

    def scrape_content
      return @scrape_content if @scrape_content
      @scrape_content = CGI.unescape( scrape_container(@scrape_target).first.inner_html )
        .gsub(/\n/, '')
        .gsub(/\"/, "'")
        .gsub(/\<\!\-\-.*?\-\-\>/, '')
        .gsub(/\<script\s.*?\<\/script\>/, '')
        .gsub(/\<meta\s.*?\>/, '')
        .gsub(/\<[^<>]*?data-description\=\'[^<>]*?\'[^<>]*?\>/, '')
    end

  end
end