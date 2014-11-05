require 'spec_helper'

module Scrapers

  describe Fodors do

    include ScraperHelper

    describe "botero" do

      before do 
        @base_name = 'botero'
        @url = 'http://www.fodors.com/world/south-america/colombia/bogota/review-137643.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 