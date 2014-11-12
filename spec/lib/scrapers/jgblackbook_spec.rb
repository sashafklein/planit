require 'spec_helper'

module Scrapers

  describe Stay do

    include ScraperHelper

    describe "pierre" do

      before do 
        @base_name = 'pierre'
        @url = 'http://jgblackbook.com/destinations/explora-atacama/'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 