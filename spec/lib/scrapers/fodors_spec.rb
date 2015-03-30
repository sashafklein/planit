require 'rails_helper'

module Scrapers

  describe Fodors do

    include ScraperHelper

    it "parses botero correctly" do
      run_test :botero, 'http://www.fodors.com/world/south-america/colombia/bogota/review-137643.html'
    end

  end
end 