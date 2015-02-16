require 'rails_helper'

module Scrapers

  describe Airbnb do

    include ScraperHelper

    describe "itinerary" do

      before do 
        @base_name = 'itinerary'
        @url = 'https://www.airbnb.com/reservation/itinerary?code=ZBCAT4'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "browse" do

      before do 
        @base_name = 'browse'
        @url = 'https://www.airbnb.com/rooms/1789270'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 