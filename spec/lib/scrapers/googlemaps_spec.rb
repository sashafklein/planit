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

      it "parses nikoklein starred googlemaps correctly", :vcr do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "trouble" do
      before do 
        @base_name = 'trouble'
        @url = 'http://www.googlemaps.com/'
        @base_domain = "googlemaps"
      end

      it "parses trouble starred googlemaps correctly", :vcr do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # PRIVATE FUNCTIONS

  end
end 