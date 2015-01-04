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

    describe "hot baths" do
      before do 
        @base_name = 'hotbaths'
        @url = 'http://www.kml.com/'
        @base_domain = "kml"
      end

      it "parses hotbath kml file correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "barcelona" do
      before do 
        @base_name = 'barcelona'
        @url = 'http://www.kml.com/'
        @base_domain = "kml"
      end

      it "parses barcelona kml file correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end

end 