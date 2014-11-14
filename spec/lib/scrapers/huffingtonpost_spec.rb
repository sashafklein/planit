require 'spec_helper'

module Scrapers

  describe Huffingtonpost do

    include ScraperHelper

    describe "cartagena" do

      before do 
        @base_name = 'cartagena'
        @url = 'http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html'
        @base_domain = get_domain(@url)
      end

      it "parses the page correctly" do
        expect_equal(data, expectations)
        expect(data).to eq expectations
      end
    end

  end
end 