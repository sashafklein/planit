require 'rails_helper'

module Scrapers

  describe Foursquare do

    include ScraperHelper

    # VENUE

    it "parses contigo correctly" do
      run_test 'contigo', 'https://foursquare.com/v/contigo/49c6bdfef964a52077571fe3'
    end

    it "parses fuunji correctly" do
      run_test 'fuunji', 'https://foursquare.com/v/%E9%A2%A8%E9%9B%B2%E5%85%90/4b5983faf964a520ca8a28e3'
    end

    # ITEM

    it "parses artoftable correctly" do
      run_test 'artoftable', 'https://foursquare.com/item/4e31cda4b61c615a55c46413'
    end
    
    # LIST

    it "parses 38list correctly" do
      run_test '38list', 'https://foursquare.com/eater/list/seattle-eater-38'
    end

    it "parses todo correctly" do
      run_test 'todo', 'https://foursquare.com/user/632549/list/todos'
    end
  end
end 