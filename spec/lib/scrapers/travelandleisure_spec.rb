require 'spec_helper'

module Scrapers

  describe Travelandleisure do

    include ScraperHelper

    describe "pestagua" do

      before do 
        @base_name = 'pestagua'
        @url = 'http://www.travelandleisure.com/travel-guide/cartagena/hotels/casa-pestagua'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    describe "lively" do

      before do 
        @base_name = 'lively'
        @url = 'http://www.travelandleisure.com/trips/trip-guide-to-lively-cartagena-colombia'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    describe "retreat" do

      before do 
        @base_name = 'retreat'
        @url = 'http://www.travelandleisure.com/articles/cartagena-a-hidden-retreat'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 