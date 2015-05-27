require 'rails_helper'

module Scrapers

  describe Nytimes do

    include ScraperHelper

    # RESTAURANT REVIEW (NYC ONLY)

      # it "parses jeangeorges correctly" do 
      #   run_test 'jeangeorges', 'http://www.nytimes.com/2014/04/09/dining/restaurant-review-jean-georges-on-the-upper-west-side.html'
      # end

    # NEW FAKE MAPS

    it "parses fakemap correctly" do 
      run_test 'fakemap', 'http://www.nytimes.com/2014/11/16/travel/a-guide-to-tokyo-from-an-outsider-and-insider-.html?ref=travel&_r=0', [], true
    end

    # TRAVEL GENERAL FORMATS

    it "parses foodies correctly" do 
      run_test 'foodies', 'http://www.nytimes.com/2008/10/26/travel/26choice.html?pagewanted=all&_r=0', [], true
    end

    it "parses india correctly" do 
      run_test 'india', 'http://www.nytimes.com/2012/03/25/travel/through-indias-desert-cities-three-itineraries.html?pagewanted=all&_r=0', [], true
    end

    # NEW 36 HOUR FORMATS

    it "parses tahoe correctly" do 
      run_test 'tahoe', 'http://www.nytimes.com/2015/03/01/travel/what-to-do-in-36-hours-lake-tahoe.html?rref=collection/column/36-hours&module=Ribbon&version=origin&region=Header&action=click&contentCollection=36%20Hours&pgtype=article', [], true
    end

    it "parses dublin correctly" do 
      run_test 'dublin', 'http://www.nytimes.com/2014/11/16/travel/things-to-do-in-36-hours-in-dublin-ireland.html?_r=0', [], true
    end

    it "parses berkeley correctly" do 
      run_test 'berkeley', 'http://www.nytimes.com/2014/10/12/travel/things-to-do-in-36-hours-in-berkeley-calif.html'
    end

    # OLD 36 HOUR FORMATS

    it "parses cartagena correctly" do 
      run_test 'cartagena', 'http://www.nytimes.com/2014/09/14/travel/things-to-do-in-36-hours-in-cartagena-colombia.html?_r=0', [], true
    end

    it "parses bogota correctly" do 
      run_test 'bogota', 'http://www.nytimes.com/2010/07/04/travel/04hours.html?pagewanted=all&_r=0'
    end

    it "parses amelia correctly" do 
      run_test 'amelia-island', 'http://www.nytimes.com/2003/12/12/travel/journeys-36-hours-amelia-island-fla.html?pagewanted=all', [], true
    end

  end
end 