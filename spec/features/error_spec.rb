require 'rails_helper'

describe 'Errors' do

  describe "404 page" do

    it "gets rendered when a bad path is visited" do
      visit '/madeup-bullshit-path'
      expect( page ).to have_content "Uh Oh: 404"
      expect( page.html ).to include "mailto:hello@plan.it"
    end
  end

  describe "500 page" do
    it "gets rendered when a path without an object is visited" do
      expect_any_instance_of( ApplicationController ).to receive(:report_error)
      visit place_path(100)
      expect( page ).to have_content "Uh Oh: 500"
      expect( page ).to have_content "The place you're looking for doesn't seem to exist!"
      expect( page ).to have_content "We've been notified"
    end
  end
end