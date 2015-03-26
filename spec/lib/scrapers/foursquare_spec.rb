require 'rails_helper'

module Scrapers

  describe Foursquare do

    include ScraperHelper

    describe "contigo" do

      before do 
        @base_name = 'contigo'
        @url = 'https://foursquare.com/v/contigo/49c6bdfef964a52077571fe3'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 