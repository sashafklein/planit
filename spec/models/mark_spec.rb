require 'rails_helper'

describe Mark do

  describe "validations" do
    it "needs a user (and user_id)" do
      user = build(:user)
      mark = Mark.new
      expect( mark.valid? ).to eq false
      
      mark.user = user
      expect( mark.user ).to eq user
      expect( mark.valid? ).to eq false
      
      user.save!
      mark.user = user
      expect( mark.valid? ).to eq true
    end
  end
  
end