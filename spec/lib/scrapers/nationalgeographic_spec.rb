require 'spec_helper'

module Scrapers

  describe Nationalgeographic do

    include ScraperHelper

    describe "tayrona" do

      before do 
        @base_name = 'tayrona'
        @url = 'http://www.nationalgeographic.com/favorites/colombia/tayrona-national-park/reviews/935/'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # describe "guadalupe" do

    #   before do 
    #     @base_name = 'guadalupe'
    #     @url = 'http://travel.nationalgeographic.com/travel/national-parks/guadalupe-mountains-national-park/'
    #     @base_domain = get_domain(@url)
    #   end

    #   it "parses the page correctly" do
    #     expect(data).to eq expectations
    #   end
    # end

  end
end 