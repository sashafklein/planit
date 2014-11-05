require 'spec_helper'

module Scrapers

  describe Booking do

    include ScraperHelper

    describe "tayrona" do

      before do 
        @base_name = 'tayrona'
        @url = 'http://www.booking.com/hotel/co/tayrona-tented-lodge.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 