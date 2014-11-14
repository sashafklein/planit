require 'spec_helper'

module Scrapers

  describe Frommers do

    include ScraperHelper

    describe "arch" do

      before do 
        @base_name = 'arch'
        @url = 'http://www.frommers.com/destinations/rome/attractions/866798'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "inroma" do

      before do 
        @base_name = 'inroma'
        @url = 'http://www.frommers.com/destinations/rome/restaurants/866665'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # CLEAN LISTS

    describe "restaurantlist" do

      before do 
        @base_name = 'restaurantlist'
        @url = 'http://www.frommers.com/destinations/rome/restaurants'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # MULTIPLE

    describe "performingarts" do

      before do 
        @base_name = 'performingarts'
        @url = 'http://www.frommers.com/destinations/rome/705646'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "leyva" do

      before do 
        @base_name = 'leyva'
        @url = 'http://www.frommers.com/destinations/bogota/278016'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "threedays" do

      before do 
        @base_name = 'threedays'
        @url = 'http://www.frommers.com/destinations/rome/705674'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "cerveteri" do

      before do 
        @base_name = 'cerveteri'
        @url = 'http://www.frommers.com/destinations/rome/705658'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 