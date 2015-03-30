require 'rails_helper'

module Scrapers

  describe Booking do

    include ScraperHelper

    it "parses itinerary correctly" do
      run_test :tayrona, 'http://www.booking.com/hotel/co/tayrona-tented-lodge.html'
    end
    
  end
end 