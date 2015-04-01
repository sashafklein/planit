require 'rails_helper'

describe StaticsController do
  describe "auto_signin" do

    before do 
      @user = create(:user)
    end

    it "rejects attempts without sufficient credentials" do
      expect( get :auto_signin ).to redirect_to beta_path
      expect( get :auto_signin, email: @user.email ).to redirect_to beta_path
      expect( get :auto_signin, token: @user.auto_signin_token ).to redirect_to beta_path
    end

    it "rejects attempts with bad credentials" do
      expect( get :auto_signin, token: @user.auto_signin_token + '1', email: @user.email ).to redirect_to beta_path
    end

    it "rejects an attempt with a bad email" do
      expect( get :auto_signin, token: @user.auto_signin_token, email: 'fake@email.com' ).to redirect_to beta_path
    end

    it "signs a credentialed user in and redirects them to the places page" do
      expect( controller.current_user ).to eq nil
      expect( get :auto_signin, token: @user.auto_signin_token, email: @user.email ).to redirect_to places_user_path(@user)
      expect( controller.current_user ).to eq @user
      expect( flash[:success] ).to eq "You've been successfully signed in."
    end
  end
end