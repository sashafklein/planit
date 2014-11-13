require 'spec_helper'

module Scrapers

  describe Yelp do

    include ScraperHelper

    describe "comptoir" do

      before do 
        @base_name = 'comptoir'
        @url = 'http://www.yelp.com/biz/le-comptoir-du-relais-paris'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "contigo" do

      before do 
        @base_name = 'contigo'
        @url = 'http://www.yelp.com/biz/contigo-san-francisco-2'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 