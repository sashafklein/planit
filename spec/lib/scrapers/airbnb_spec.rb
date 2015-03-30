require 'rails_helper'

module Scrapers

  describe Airbnb do

    include ScraperHelper


    it "parses itinerary correctly" do
      run_test :itinerary, 'https://www.airbnb.com/reservation/itinerary?code=ZBCAT4'
    end

    it "parses itinerary correctly" do
      run_test :browse, 'https://www.airbnb.com/rooms/1789270'
    end

  end
end 