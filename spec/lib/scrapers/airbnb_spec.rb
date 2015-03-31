require 'rails_helper'

module Scrapers

  describe Airbnb do

    include ScraperHelper


    it "parses itinerary correctly" do
      run_test :itinerary, 'https://www.airbnb.com/reservation/itinerary?code=ZBCAT4'
    end

    it "parses browse correctly" do
      run_test :browse, 'https://www.airbnb.com/rooms/1789270'
    end

    it "parses slc_reservation correctly" do
      run_test :slc_reservation, 'https://www.airbnb.com/reservation/receipt?code=3DRD9A'
    end

  end
end 