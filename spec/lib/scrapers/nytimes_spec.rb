require 'rails_helper'

module Scrapers

  describe Nytimes do

    include ScraperHelper

    # RESTAURANT REVIEW (NYC ONLY)

    # describe "jeangeorges" do

    #   before do 
    #     @base_name = 'jeangeorges'
    #     @url = 'http://www.nytimes.com/2014/04/09/dining/restaurant-review-jean-georges-on-the-upper-west-side.html'
    #     @base_domain = get_domain(@url)
    #   end

    #   it "parses the page correctly" do
    #     expect_equal(data, expectations)
    #     expect(data).to eq expectations
    #   end
    # end

    # NEW FAKE MAPS

    describe "fakemap" do

      before do 
        @base_name = 'fakemap'
        @url = 'http://www.nytimes.com/2014/11/16/travel/a-guide-to-tokyo-from-an-outsider-and-insider-.html?ref=travel&_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # TRAVEL GENERAL FORMATS

    describe "foodies" do

      before do 
        @base_name = 'foodies'
        @url = 'http://www.nytimes.com/2008/10/26/travel/26choice.html?pagewanted=all&_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "india" do

      before do 
        @base_name = 'india'
        @url = 'http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # NEW 36 HOUR FORMATS

    describe "tahoe" do
      before do 
        @base_name = 'tahoe'
        @url = 'http://www.nytimes.com/2015/03/01/travel/what-to-do-in-36-hours-lake-tahoe.html?rref=collection/column/36-hours&module=Ribbon&version=origin&region=Header&action=click&contentCollection=36%20Hours&pgtype=article'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "dublin" do

      before do 
        @base_name = 'dublin'
        @url = 'http://www.nytimes.com/2014/11/16/travel/things-to-do-in-36-hours-in-dublin-ireland.html?_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "berkeley" do

      before do 
        @base_name = 'berkeley'
        @url = 'http://www.nytimes.com/2014/10/12/travel/things-to-do-in-36-hours-in-berkeley-calif.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # OLD 36 HOUR FORMATS

    describe "cartagena" do

      before do 
        @base_name = 'cartagena'
        @url = 'http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "bogota" do

      before do 
        @base_name = 'bogota'
        @url = 'http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end
    
    describe "amelia island" do

      before do 
        @base_name = 'amelia-island'
        @url = 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 