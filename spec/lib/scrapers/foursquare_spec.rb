require 'rails_helper'

module Scrapers

  describe Foursquare do

    include ScraperHelper

    # VENUE

    describe "contigo" do

      before do 
        @base_name = 'contigo'
        @url = 'https://foursquare.com/v/contigo/49c6bdfef964a52077571fe3'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "fuunji" do

      before do 
        @base_name = 'fuunji'
        @url = 'https://foursquare.com/v/%E9%A2%A8%E9%9B%B2%E5%85%90/4b5983faf964a520ca8a28e3'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # ITEM

    describe "artoftable" do

      before do 
        @base_name = 'artoftable'
        @url = 'https://foursquare.com/item/4e31cda4b61c615a55c46413'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    # LIST

    describe "38list" do

      before do 
        @base_name = '38list'
        @url = 'https://foursquare.com/eater/list/seattle-eater-38'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

    describe "todo" do

      before do 
        @base_name = 'todo'
        @url = 'https://foursquare.com/user/632549/list/todos'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 