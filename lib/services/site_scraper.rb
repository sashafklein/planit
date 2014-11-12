module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    require 'json'
    include RegexLibrary
    include CssOperators

    def self.build(url, page=nil)
      specific_scraper(url, page)
    end

    attr_accessor :url, :page
    delegate :css, to: :page
    def initialize(url, page)
      @url = url
      @page = Nokogiri::HTML( page.present? ? page : open(url) )
      @data = []
    end

    # PAGE FLOW

    def data
      return @data if @data.length > 0
      
      # WE NEED SOME FORM OF NILSINK HERE IF GROUPS TURN UP NIL
      # undefined method `each_with_index' for nil:NilClass
      # binding.pry

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
          # itinerary_data(itinerary, itinerary_index), 
          global_data,
        ])
      end
      # binding.pry
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
    def day_group(leg);                             [section_group(nil)];    end
    def day_data(day, day_index);                   {};                 end
    def section_group(day);                         [activity_group(nil)];   end
    def section_data(section, section_index);       {};                 end
    def activity_group(section);                    [];                 end
    def activity_data(activity, activity_index);    {};                 end
    def general_group;                              [];                 end
    def general_data(general, general_index);       {};                 end

    def full_item(datas_array)
      progressive_merge(datas_array)
    end

    def progressive_merge(array_of_hashes)
      array_of_hashes.inject({}) { |f, h| f.merge(h) }
    end

    # OPERATIONS
    
    def remove_punc(string)
      string.scan(remove_final_punctuation_regex).first.first ; rescue ; string
    end

    def find_country(string)
      Carmen::Country.all.map(&:name).find{ |c| no_accents(string).include?(no_accents(c)) }
    end

    def find_region(string, country)
      carmen_country = Carmen::Country.named(country)
      carmen_country.subregions.map(&:name).find{ |sr| no_accents(string).include?(no_accents(sr)) }
    end

    # def find_locality(string, subregion, country)
    #   carmen_country = Carmen::Country.named(country)
    #   carmen_subregion = Carmen::Country.named(country)
    #   carmen_country.subregions.map(&:name).find{ |sr| no_accents(string).include?(no_accents(sr)) }
    # end

    def scrape_container(list)
      return @scrape_container if @scrape_container
      selector = list.select{ |sel| css(sel).any? }.first
      @scrape_container = css(selector) if selector
    end

    def illegal_content # DOUBLE \\
      illegal_content_array = [
        "\\<div [^>]*class\\=\\'[^\\s']*ad\\s[^']*\\'\\>.*?\\<\\/div\\>",
        "\\<\\!\\-\\-.*?\\-\\-\\>",
        "\\<script(?:\\s|\\>).*?\\<\\/script\\>",
        "\\<style(?:\\s|\\>).*?\\<\\/style\\>",
        "\\<figure(?:\\s|\\>).*?\\<\\/figure\\>",
        "\\<div\\s[^>]*?(?:g\\-type\\_Inset|g\\-aiAbs)[^>]*?\\>.*?\\<\\/div\\>",
        "\\<meta\\s.*?\\>",
        "\\<[^<>]*?data-description\\=\\'[^<>]*?\\'[^<>]*?\\>",
        "\\<header(?:\\s|\\>).*?\\<\\/header\\>",
        "\\<nav(?:\\s|\\>).*?\\<\\/nav\\>",
        "\\<form(?:\\s|\\>).*?\\<\\/form\\>",
        # "\\<[^<>]*?story-meta\\=\\'[^<>]*?\\'[^<>]*?\\>",
      ]
    end

    def scrape_content
      return @scrape_content if @scrape_content
      @scrape_content = CGI.unescape( scrape_container(@scrape_target).first.inner_html )
      @scrape_content = @scrape_content.gsub(/\s\s+/, "  ") #maximum 2 spaces
      @scrape_content = @scrape_content.gsub(/\n/, '')
      @scrape_content = @scrape_content.gsub(/[\u00AD]/, '')
      @scrape_content = @scrape_content.gsub(/\"/, "'")
      0.upto(illegal_content.length - 1).each do |i|
        @scrape_content = @scrape_content.gsub(%r!#{illegal_content[i]}!, '')
      end
      return @scrape_content
    end

    def no_accents(string)
      I18n.transliterate string
    end
  end
end