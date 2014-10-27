module Services
  class SiteScraper
    
    require 'uri'

    def self.build(url, html)
      return specific_scraper(url, html)
    end

    attr_accessor :url, :page
    delegate :css, to: :page
    def initialize(url, page)
      @url = url
      @page = Nokogiri::HTML page
    end

    private

    def self.specific_scraper(url, page)
      if url.include?('nytimes.com')
        Scrapers::Nytimes.new(url, page)
      end
    end

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