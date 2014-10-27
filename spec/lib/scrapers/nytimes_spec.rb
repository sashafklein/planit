require 'spec_helper'

module Scrapers

  describe Nytimes do

    include ScraperHelper

    describe "amelia island" do

      before do 
        @base_name = 'amelia-island'
        @base_domain = 'nytimes'
        @url = 'view-source:http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all'
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end
  end
end 