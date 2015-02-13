require 'rails_helper'

describe String do
  describe "no_accents" do
    it 'returns an unaccented version' do 
      string = "Ï gôt âçćéñts"
      expect(string.no_accents).to eq "I got accents"
      expect(string).to eq "Ï gôt âçćéñts"
    end
  end

  describe "cut" do
    it "removes substrings one after another" do
      string = "3976 San Francisco CA USA"
      expect(string.cut 'San Francisco', 'CA', 'USA' ).to eq "3976   "
      expect(string.cut ['San Francisco', 'CA', 'USA'] ).to eq "3976   "
    end
  end

  describe "match_distance" do
    it "calculates string disimilarities" do
      expect( "I got açcéñts".match_distance("I got accents") ).to eq 1.0
      expect( "I got açcéñts".match_distance("I got accent") ).to be_within( 0.1 ).of( 1 )
      expect( "Some random ass crap".match_distance("Whatever") ).to be < 0.5
    end

    it "doesn't try with weird characters" do
      expect( "代々木 Whatever".match_distance("I got accents") ).to eq nil
    end
  end

  describe "without_articles" do
    it "removes articles from a string" do
      expect( "The string with el bunch of los the article things".without_articles ).to eq("string with bunch of article things")
    end

    it "can take an article array" do
      expect( "A string with a bunch of the article things".without_articles( %w(a the of)) ).to eq("string with bunch article things")
    end
  end
end