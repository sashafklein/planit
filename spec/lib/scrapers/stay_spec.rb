require 'spec_helper'

module Scrapers

  describe Stay do

    include ScraperHelper

    describe "pierre" do

      before do 
        @base_name = 'pierre'
        @url = 'http://www.stay.com/new-york/hotel/4986/the-pierre-a-taj-hotel-new-york/'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    describe "jetsetters" do

      before do 
        @base_name = 'jetsetters'
        @url = 'http://www.stay.com/new-york/guides/296846-dbc0095d/new-york-for-jetsetters/'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end
    
    describe "nyhigh" do

      before do 
        @base_name = 'nyhigh'
        @url = 'http://www.stay.com/new-york/'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 