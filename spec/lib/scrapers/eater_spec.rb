require 'spec_helper'

module Scrapers

  describe Eater do

    include ScraperHelper

    describe "apizza-scholls" do

      before do 
        @base_name = 'apizza-scholls'
        @url = 'http://pdx.eater.com/maps/portland-best-restaurants-kachka-davenport/apizza-scholls'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end
  end
end 