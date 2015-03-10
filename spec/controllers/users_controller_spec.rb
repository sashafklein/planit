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
      expect( flash[:error] ).to eq "Sorry! No public access to this page. Sign in to continue."
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

    it "rejects attempt to invite by non-user" do
      params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' }

      expect_any_instance_of(User).not_to receive(:save_as).with(:member).and_call_original

      expect{
        post :invite, user: params
      }.to change{ User.where(params).count }.by 0
    end

    it "rejects attempt to invite by non-member" do
      @user.pending!
      sign_in @user
      params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' }

      expect_any_instance_of(User).not_to receive(:save_as).with(:member).and_call_original

      expect{
        post :invite, user: params
      }.to change{ User.where(params).count }.by 0
    end

    it "shares correct invitee info with save as member" do
      @user.admin!
      sign_in @user
      params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' }

      expect_any_instance_of(User).to receive(:save_as).with(:member).and_call_original

      expect{
        post :invite, user: params
      }.to change{ User.where(params).count }.by 1
    end

    it "shares correct beta info with save as pending" do
      params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' }

      expect_any_instance_of(User).to receive(:save_as).with(:pending).and_call_original

      expect{
        post :beta, user: params
      }.to change{ User.where(params).count }.by 1
    end

  end
end