module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    require 'json'
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
      
      # WE NEED SOME FORM OF NILSINK HERE IF GROUPS TURN UP NIL
      # undefined method `each_with_index' for nil:NilClass

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
    
    def calculate_rating(string, base)
      #clean rating string
      if string && string.length > 0
        rate = string.scan(/.*?(\d+\.?\d*)(?: of \d+\.?\d*)?.*?/).flatten.first.to_f
      end
      if rate && base
        return ( (rate.to_f * 100) / base ).round
      end
    rescue ; nil
    end

    def remove_punc(string)
      string.scan(remove_final_punctuation_regex).first.first ; rescue ; string
    end

    def find_country(string)
      if string
        country = Carmen::Country.all.find{ |c| no_accents(string).include?(no_accents(c.name)) }
        country ||= Carmen::Country.all.find{ |c| (string).include?("#{c.alpha_3_code.titleize}.") } 
        country ||= Carmen::Country.all.find{ |c| (string).include?(c.alpha_3_code.upcase) } 
        country.try(:name)
      end
    rescue ; nil
    end

    def find_region(string, country)
      if string && country
        carmen_country = Carmen::Country.named(country)
        region = carmen_country.subregions.find{ |sr| no_accents(string).include?(no_accents(sr.name)) }
        region ||= carmen_country.subregions.find{ |sr| no_accents(string).include?("#{no_accents(sr.name).first(3)}.") }
        region ||= carmen_country.subregions.find{ |sr| string.include?(sr.code.upcase) }
        region.try(:name)
      end
    rescue ; nil
    end

    def find_locality(string)
      if string
        # carmen_country = Carmen::Country.named(country)
        # country_code = carmen_country.code
        # City.where(country_code:country_code).pluck(:name).find{ |locality| no_accents(string).include?(locality) }
      end
    rescue ; nil
    end

    def p_br_to_comma(string)
      string.gsub("<br>", ", ").gsub("<p>", ", ").gsub(",,", ",").gsub(", ,", ",") ; rescue ; nil
    end

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
      if string && string.length > 0
        I18n.transliterate string
      end
    end
  end
end