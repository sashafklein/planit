module Scrapers
  class General < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if is_article?(page)
        GeneralMod::Article.new(url, page)
      # elsif is_travel_site?(page)
      #   GeneralMod::Travel.new(url, page)
      # elsif is_blog?(url, page)
      #   GeneralMod::Blog.new(url, page)
      else
        GeneralMod::Catchall.new(url, page)
      end
    end

    def self.is_article?(page)
      # replace this later
      return false
      # end replace
      page = Nokogiri::HTML page
      if page_count_beyond_threshold?(page, /(?:article|Article|ARTICLE)/, 40)
        if article_container = get_usual_suspect_text(article_usual_suspects, page)
          return true unless article_container.length == 0
        end
      end
      return nil
    end

    def self.is_blog?(url, page)
      page = Nokogiri::HTML page
      blog_platforms = [
        "wordpress",
        "svbtle",
        "tumblr",
        "blogger",
        "typepad",
        "posthaven",
        "blogspot",
      ]
      blog_platforms.each do |platform|
        if url.include?(".#{platform}.")
          return true
        elsif page_count_beyond_threshold?(page, /(?:#{platform}|#{platform.capitalize}|#{platform.upcase})/, 40)
          return true
        end
      end
    end

    def self.is_travel_site?(url)
      page = Nokogiri::HTML page
      if page_count_beyond_threshold?(page, /(?:travel|Travel|TRAVEL)/, 40)
        return true
      elsif page_count_beyond_threshold?(page, /(?:destination|Destination|DESTINATION)/, 40)
        return true
      end
      return nil
    end

  end
end