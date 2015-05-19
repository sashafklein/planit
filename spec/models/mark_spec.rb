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
      expect( mark2.errors.full_messages.first ).to eq "A Mark with that user_id and place_id already exists. mark_id: #{mark1.id}, user_id: #{mark1.user_id}, place_id: #{mark1.place_id}"
      expect{ mark2.save! }.to raise_error
    end
  end

  describe "copy" do
    it "can be done a number of times without erroring" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)
      mark = create(:mark)

      expect{ 
        mark.copy!(new_user: user1)
        mark.copy!(new_user: user2)
        mark.copy!(new_user: user3)
      }.not_to raise_error

      expect( Mark.count ).to eq 4
      [user1, user2, user3].each do |u|
        expect( u.reload.marks.count ).to eq 1
      end
    end

    it "handles redundancy" do
      mark = create(:mark)
      expect{
        mark.copy!(new_user: mark.user)      
      }.not_to raise_error
    end
  end
  
end