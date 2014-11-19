module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    require 'json'
    require 'nokogiri'
    include RegexLibrary
    extend RegexLibrary
    include CssOperators
    extend CssOperators
    include GeoQueries

    def self.build(url, page=nil)
      specific_scraper(url, page)
    end

    attr_accessor :url, :page
    delegate :css, to: :page
    def initialize(url, page=nil)
      @url = url
      @page = Nokogiri::HTML( page ? page : open(url) )
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
          itinerary_data(nil, nil), #MAY NEEDSFOLLOWUP 
          global_data,
        ])
      end
      @data
    end

    private

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

    def full_item(datas_array)
      progressive_merge(datas_array)
    end

    def progressive_merge(array_of_hashes)
      array_of_hashes.inject({}) { |f, h| f.deep_merge(h) }
    end

    # OPERATIONS
    
    def calculate_rating(string, base=nil)
      if string && string.length > 0
        rate = string.scan(/.*?(\d+\.?\d*)(?: (?:out )?of (\d+\.?\d*))?.*?/).flatten.first.to_f
        unless base
          base = string.scan(/.*?(\d+\.?\d*)(?: (?:out )?of (\d+\.?\d*))?.*?/).flatten[1].to_f
        end
      end
      if rate && base
        return ( (rate.to_f * 100) / base ).round
      end
    end

    def remove_punc(string)
      string.scan(remove_final_punctuation_regex).first.first ; rescue ; string
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

    def top_pick(guesses, threshold=0.5)
      if guesses && guesses.compact.uniq.length == 1
        return [guesses.compact.uniq.first, 1]
      elsif guesses && guesses.compact.uniq.length > 1
        top = 0
        top_guess = ""
        guesses.compact.uniq.each do |guess|
          if guesses.select{ |e| e == guess }.length > top
            top = guesses.select{ |e| e == guess }.length 
            top_guess = guess
          elsif guesses.select{ |e| e == guess }.length == top
            # strict no-equals rule would be to un-comment the below
            # top_guess = ""
          end
        end
        confidence = (top.to_f / guesses.compact.length.to_f)
        if confidence > threshold
          return [top_guess, confidence]
        end
      end
      return []
    rescue ; nil
    end

  end
end