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

    it "redirects for same user" do 
      sign_in @user

      get :show, id: @user.id
      expect( response ).to redirect_to root_path
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
        post :waitlist, user: params
      }.to change{ User.where(params).count }.by 1
    end

  end
end