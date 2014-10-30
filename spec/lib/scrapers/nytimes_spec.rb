require 'spec_helper'

module Scrapers

  describe Nytimes do

    include ScraperHelper

    describe "cartagena" do

      before do 
        @base_name = 'cartagena'
        @url = 'http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    describe "amelia island" do

      before do 
        @base_name = 'bogota'
        @url = 'http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

    describe "amelia island" do

      before do 
        @base_name = 'amelia-island'
        @url = 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect(scraper.data).to eq expectations
      end
    end

  end
end 