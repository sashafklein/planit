require 'rails_helper'

describe UsersController do

  before do 
    @user = create(:user)
  end

  describe "show" do

    before do 
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
  end

  describe "invite" do

    before { @params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' } }

    it "rejects attempt to invite by non-user" do
      expect_any_instance_of(User).not_to receive(:invite!).and_return true

      post :invite, user: @params
    end

    it "invites as member" do
      sign_in @user

      expect_any_instance_of(User).to receive(:invite!).and_return true

      post :invite, user: @params
    end
  end

  describe "waitlist" do
    
    before { @params = { first_name: 'test', last_name: 'tests', email: 'test@tests.com' } }

    it "shares correct beta info with save as pending" do
      expect(MailListEmail).to receive(:waitlist!).with(@params)

      post :waitlist, user: @params
    end

  end
end