require 'spec_helper'

module Scrapers

  describe Googlemaps do

    include ScraperHelper

    describe "nikoklein" do
      before do 
        @base_name = 'nikoklein'
        @url = 'http://www.googlemaps.com/'
        @base_domain = "googlemaps"
      end

      xit "parses nikoklein starred googlemaps correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # PRIVATE FUNCTIONS

  end
end 