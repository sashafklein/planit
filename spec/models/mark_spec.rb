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

  describe "creation" do
    it "validates group_uniqueness of place_id and user_id" do
      mark1 = create(:mark)
      mark2 = build(:mark, place_id: mark1.place_id, user_id: mark1.user_id)
      
      expect( mark2.valid? ).to eq false
      expect( mark2.errors.full_messages.first ).to eq "A Mark with that user_id and place_id already exists. ID: #{mark1.id}"
      expect{ mark2.save! }.to raise_error
    end
  end
  
end