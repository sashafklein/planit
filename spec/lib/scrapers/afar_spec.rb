require 'rails_helper'

module Scrapers

  describe Afar do

    include ScraperHelper

    describe "desal" do

      before do 
        @base_name = 'desal'
        @url = 'http://www.afar.com/places/catedral-de-sal-zipaquira?context=travel-guide&country=colombia'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 