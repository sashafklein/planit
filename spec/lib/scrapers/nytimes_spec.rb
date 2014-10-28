require 'spec_helper'

module Scrapers

  describe Nytimes do

    include ScraperHelper

    describe "amelia island" do

      before do 
        @base_name = 'amelia-island'
        @base_domain = 'nytimes'
        @url = 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all'
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    # describe "cartagena" do

    #   before do 
    #     @base_name = 'cartagena'
    #     @base_domain = 'nytimes'
    #     @url = 'http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0'
    #   end

    #   it "parses the page correctly" do
    #     expect(scraper.data).to eq expectations
    #   end
    # end

  end
end 