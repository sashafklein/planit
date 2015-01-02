require 'spec_helper'

module Scrapers

  describe Googlemaps do

    include ScraperHelper

    describe "maine" do
      before do 
        @base_name = 'maine'
        @url = 'http://www.kml.com/'
        @base_domain = "kml"
      end

      it "parses maine kml file correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "japan" do
      before do 
        @base_name = 'japan'
        @url = 'http://www.kml.com/'
        @base_domain = "kml"
      end

      it "parses japan kml file correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # PRIVATE FUNCTIONS
  end

end 