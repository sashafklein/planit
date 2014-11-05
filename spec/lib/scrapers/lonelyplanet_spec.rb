require 'spec_helper'

module Scrapers

  describe Lonelyplanet do

    include ScraperHelper

    describe "cevicheria" do

      before do 
        @base_name = 'cevicheria'
        @url = 'http://www.lonelyplanet.com/colombia/caribbean-coast/cartagena/restaurants/seafood/la-cevicheria?rte=current'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 