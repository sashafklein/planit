require 'rails_helper'

module Scrapers

  describe Yelp do

    include ScraperHelper

    it "parses comptoir correctly" do
      run_test 'comptoir', 'http://www.yelp.com/biz/le-comptoir-du-relais-paris'
    end

    it "parses contigo correctly" do
      run_test 'contigo', 'http://www.yelp.com/biz/contigo-san-francisco-2'
    end

  end
end 