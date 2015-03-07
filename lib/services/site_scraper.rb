module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    require 'json'
    include RegexLibrary
    extend RegexLibrary
    include UsualSuspects
    extend UsualSuspects
    include CssOperators
    extend CssOperators
    include ScraperOperators
    extend ScraperOperators
    include GeoQueries

    def self.build(url, page=nil)
      specific_scraper(url, page)
    end

    attr_accessor :url, :page
    delegate :css, to: :page
    def initialize(url, page=nil)
      @url = url
      @page = Nokogiri::HTML( page ? page : safe_open(url) )
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
                  global_data,
                ])
                @data << item
              end
            end
          end
        end
      end

      general_group.each_with_index do |general, general_index|
        @data << full_item([
          general_data(general, general_index),
          itinerary_data(itinerary=nil, itinerary_index=nil),
          global_data,
        ])
      end
      @data
    end

    private

    def safe_open(url)
      return open(url) unless Rails.env.test?
      
      WebMock.disable!
      resp = open(url)
      WebMock.enable!
      resp
    end

    def self.specific_scraper(url, page)
      class_name = URI(url).host.match(/[^\.]+\.\w+$/).to_s.split('.').first.capitalize
      scraper = supported_scrapers.include?(class_name) ? "Scrapers::#{class_name}".constantize : Scrapers::General
      scraper.build(url, page)
    end

    def self.supported_scrapers
      Dir.entries( File.join(Rails.root, 'lib', 'scrapers') ).select{ |e| e[-3..-1] == '.rb' }.map{ |e| e[0..-4] }.map(&:capitalize)
    end

    # FLOW DEFAULTS

    def itinerary_group;                            [leg_group(nil)];   end
    def itinerary_data(itinerary, itinerary_index); {};                 end
    def leg_group(itinerary);                       [day_group(nil)];   end
    def leg_data(leg, leg_index);                   {};                 end
    def day_group(leg);                             [section_group(nil)];    end
    def day_data(day, day_index);                   {};                 end
    def section_group(day);                         [activity_group(nil)];   end
    def section_data(section, section_index);       {};                 end
    def activity_group(section);                    [];                 end
    def activity_data(activity, activity_index);    {};                 end
    def general_group;                              [];                 end
    def general_data(general, general_index);       {};                 end
    def global_data;                                {};                 end

    def full_item(datas_array)
      progressive_merge(datas_array)
    end

    def progressive_merge(array_of_hashes)
      @test = array_of_hashes
      array_of_hashes.inject({}) { |f, h| f.deep_merge(h) }
    end

  end
end