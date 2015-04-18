require 'rails_helper'

describe UrlObjectParser do
  describe "objects" do
    it "parses the shit out of models" do 
      expect( UrlObjectParser.new('users/some-name/marks/19/places').objects ).to hash_eq({
        'User' => 'some-name',
        'Mark' => '19' 
      })
    end

    it "ignores non-models" do
      expect( UrlObjectParser.new('users/some-name/bullshit/19/places').objects ).to hash_eq({
        'User' => 'some-name'
      })
    end

    it "parses the shit out of querystrings" do
      expect( UrlObjectParser.new('localhost:3000/?plan=100').objects ).to hash_eq({
        'Plan' => '100' 
      })
    end
  end
end