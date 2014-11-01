require 'spec_helper'

module Scrapers

  describe Tripadvisor do

    include ScraperHelper

    describe "fuunji" do

      before do 
        @base_name = 'fuunji'
        @url = 'http://www.tripadvisor.com/Restaurant_Review-g1066456-d1679642-Reviews-Fuunji-Shibuya_Tokyo_Tokyo_Prefecture_Kanto.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 