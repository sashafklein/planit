require 'spec_helper'

module Scrapers

  describe Eater do

    include ScraperHelper

    describe "nico" do

      before do 
        @base_name = 'nico'
        @url = 'http://sf.eater.com/venue/nico'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(data).to eq expectations
      end
    end

    describe "sitka" do

      before do 
        @base_name = 'sitka'
        @url = 'http://www.eater.com/2014/10/17/6994765/sitka-and-spruce-restaurant-review'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(data).to eq expectations
      end
    end

    # describe "suppers" do

    #   before do 
    #     @base_name = 'suppers'
    #     @url = 'http://sf.eater.com/2014/11/7/7174885/sunday-suppers-trendy'
    #     @base_domain = get_domain(@url)
    #   end

    #   it "parses the page correctly" do
    #     expect(data).to eq expectations
    #   end
    # end

    describe "apizza-scholls" do

      before do 
        @base_name = 'apizza-scholls'
        @url = 'http://pdx.eater.com/maps/portland-best-restaurants-kachka-davenport/apizza-scholls'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(data).to eq expectations
      end
    end

    describe "thoumieux" do

      before do 
        @base_name = 'thoumieux'
        @url = 'http://www.eater.com/maps/the-eater-paris-heatmap-where-to-eat-right-now/gateaux-thoumieux'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(data).to eq expectations
      end
    end

  end
end 