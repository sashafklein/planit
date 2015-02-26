require 'rails_helper'

describe UsersController do

  describe "show" do

    before do 
      @user = create(:user)
      @user2 = create(:user)

      mark1 = create(:mark, user_id: @user.id)
      mark2 = create(:mark, user_id: @user.id, published: false)
    end

    it "rejects non-users" do
      get :show, id: @user.id
      expect( response ).to redirect_to root_path
      expect( flash[:error] ).to eq "No Public Access"
    end

    it "shows only published plans for non-admins or users" do
      sign_in @user2
      @user2.member!
      get :show, id: @user.id
      expect( assigns[:marks].count ).to eq 1
    end

    it "shows everything for the user" do
      sign_in @user
      @user.member!
      get :show, id: @user.id
      expect( assigns[:marks].count ).to eq 2
    end

    it "shows everything for admins" do
      @user2.admin!
      sign_in @user2
      get :show, id: @user.id
      expect( assigns[:marks].count ).to eq 2
    end
  end
end