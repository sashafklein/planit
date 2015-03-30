require 'rails_helper'

module Scrapers

  describe Huffingtonpost do

    include ScraperHelper

    it "parses cartagena correctly" do
      run_test 'cartagena', 'http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html'
    end

    #   it "parses idaho correctly" do
    #     run_test 'idaho', 'http://www.huffingtonpost.com/fodors/4-reasons-to-visit-idaho_b_6110068.html'
    #   end

  end
end 