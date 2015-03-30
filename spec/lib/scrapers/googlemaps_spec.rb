require 'rails_helper'

module Scrapers

  describe Googlemaps, :vcr do

    include ScraperHelper

    #This shit is killing me -- tons of tiny irrelevant changes
    xit "parses nikoklein correctly" do
      run_test 'nikoklein', 'http://www.googlemaps.com/', [:full_address]
    end
        
    it "parses trouble correctly" do
      run_test 'trouble', 'http://www.googlemaps.com/', [:full_address]
    end
        
    # PRIVATE FUNCTIONS

  end
end 