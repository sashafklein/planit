require 'rails_helper'

describe "choose!", :vcr do

  include ScraperHelper

  before do
    @user = create(:user)
    @mark = completed_data(filename: 'cartagena', scrape_url: "http://www.huffingtonpost.com/curtis-ellis/cartagena-eat-pray-love-d_b_3479981.html", name: 'Alma')
    @option = @mark.place_options.first
  end

  it "returns the created or found right place for the option" do
    expect{ @option.choose! }.to change{ Place.count }.by 1

    place = Place.first
    expect( place.names ).to eq @option.names
    expect( place.foursquare_id ).to eq @option.foursquare_id
  end

  it "associates this place with the mark" do 
    expect{ @option.choose! }.to change{ Place.count }.by 1
    expect( Place.first.marks.first.id ).to eq @option.mark_id
  end

  it "completes the place" do
    expect{ @option.choose! }.to change{ Place.count }.by 1
    expect( Place.first.completion_steps.count ).to be > @option.completion_steps.count
    expect( @option.reservations ).to eq false
    expect( Place.first.reservations ).to eq true
  end
end
