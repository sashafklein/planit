require 'rails_helper'

describe Mark do

  before do
    @user = build(:user)
  end

  describe "validations" do
    it "needs a user (and user_id)" do
      mark = Mark.new
      expect( mark.valid? ).to eq false
      
      mark.user = @user
      expect( mark.user ).to eq user
      expect( mark.valid? ).to eq false
      
      @user.save!
      mark.user = @user
      expect( mark.valid? ).to eq true
    end
  end

  describe "creation" do
    # it "handles redundancy" do
    #   @user.save!
    #   place = Place.new
    #   mark = Mark.new( place_id: place.id, user: @user )
    #   mark2 = build(:mark)

    # end
  end
  
end