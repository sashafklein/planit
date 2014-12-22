module Scrapers
  class Email < Services::SiteScraper

    attr_accessor :section_array, :days
    def initialize(url, page)
      super(url, page)
    end

    private

    def self.specific_scraper(url, page)
      if confirmation?(url)
        # EmailMod::Confirmation.new(url, page)
      else
        EmailMod::Tips.new(url, page)
      end
    end

    def self.confirmation?(url)
      false
    end

  end
end