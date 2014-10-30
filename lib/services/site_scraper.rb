module Services
  class SiteScraper
    
    # PAGE SETUP

    require 'uri'
    include RegexLibrary

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

      # collect_data( %w(itinerary leg day section activity), [get_global_data])
      itinerary_group.each_with_index do |itinerary, itinerary_index|
        # binding.pry
        leg_group(itinerary).each_with_index do |leg, leg_index|
          # binding.pry
          day_group(leg).each_with_index do |day, day_index|
            # binding.pry
            section_group(day).each_with_index do |section, section_index|
              # binding.pry
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
      # binding.pry
    end

    # def collect_data(group_levels, data_array=[])
    #   if group_levels.any?
    #     group_level = group_levels.shift #itinerary
    #     data_array << send("get_#{group}_data") #itinerary_group
    #     send("#{group_level}_group").each do |group| #itinerary_group.each do |itinerary|
    #       collect_data(group_levels, data_array) # collect_data([leg day section activity], itinerary_data(itinerary))
    #     end
    #   else
    #     @data << full_item(data_array)
    #   end
    # end

    private

    def self.specific_scraper(url, page)
      if url.include?('nytimes.com')
        Scrapers::Nytimes.build(url, page)
      end
    end

    # FLOW DEFAULTS

    def global_data
      {}
    end

    def itinerary_group
      [leg_group(nil)]
    end
    def itinerary_data(itinerary, itinerary_index)
      {}
    end

    def leg_group(itinerary)
      [day_group(nil)]
    end
    def leg_data(leg, leg_index)
      {}
    end

    def day_group(leg)
      [section_group]
    end
    def day_data(day, day_index)
      {}
    end

    def section_group(day)
      [activity_group]
    end
    def section_data(section, section_index)
      {}
    end

    def activity_group(section)
      []
    end
    def activity_data(activity, activity_index)
      {}
    end

    def full_item(datas_array)
      progressive_merge(datas_array)
    end

    def progressive_merge(array_of_hashes)
      array_of_hashes.inject({}) { |f, h| f.merge(h) }
    end

    # OPERATIONS
    
    def scrape_container(list)
      return @scrape_container if @scrape_container
      list.each do |selector|
        return @scrape_container = css(selector) if css(selector).any?
      end
    end

    def scrape_content
      return @scrape_content if @scrape_content
      @scrape_content = scrape_container(@scrape_target).first.inner_html
      @scrape_content = CGI.unescape(@scrape_content)
      @scrape_content = @scrape_content.gsub(/\n/,'')
      @scrape_content = @scrape_content.gsub(/\"/,"'")
      @scrape_content = @scrape_content.gsub(/\<\!\-\-.*?\-\-\>/,'')
      @scrape_content = @scrape_content.gsub(/\<script\s.*?\<\/script\>/,'')
      @scrape_content = @scrape_content.gsub(/\<meta\s.*?\>/,'')
      @scrape_content = @scrape_content.gsub(/\<[^<>]*?data-description\=\'[^<>]*?\'[^<>]*?\>/,'')
    end

    def regex_split_without_loss(string_or_array, split_term)
      add_back = string_or_array.scan(split_term).flatten
      add_to = string_or_array.split(split_term).reject(&:blank?)
      0.upto(add_to.length - 1).each do |i|
        add_to[i] = add_back[i] + add_to[i]
      end
      return add_to
    end

    # CSS OPERATORS

    def split_by(selectors, split_array)
      Array(selectors).each do |selector|
        
        if ( node = css(selector) ).any?
          split_array.each do |split_by_element|
            splitter, index = split_by_element
            if node.inner_html.include?( splitter )
              return split(node, split_by_element.first, split_by_element.last)
            end
          end
        end

      end
    end

    def split(node, splitter, index)
      split_array = node.inner_html.split( splitter )
      split_array[index]
    end

    def text_selector(selector)
      if (sel = css(selector)).any?
        text = sel.inner_html
          .gsub(/\<\/*[p]\>/, "\n")
          .gsub(/\<\/*[br]\>/, "\n")
          .gsub(/\&[l][t]\;(?:.|\n)*?\&[g][t]\;/, '')
        de_tag( text )
      else
        nil
      end
    end
      
    def de_tag(html)
      html.gsub(/<(?:.|\n)*?>/, '')
    end

    def trim(html)
      html = html.gsub(/(\r\n|\n|\r)/, '')
          .gsub(/( {2,})/, ' ')
          .gsub(/^\s+|\s+$/, '')
          .gsub(/\s+/, ' ')
          .gsub(/(\t)/, '')
      URI.unescape(html)
    end
  end
end