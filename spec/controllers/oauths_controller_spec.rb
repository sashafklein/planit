require 'rails_helper'

describe OauthsController do
  describe "foursquare" do

    it "redirects to an appropriate foursquare endpoint" do
      expect(
        get :foursquare
      ).to redirect_to "https://foursquare.com/oauth2/authenticate?client_id=#{ Env.foursquare_client_id }&response_type=code&redirect_uri=http://test.host/oauths/foursquare_return"
    end
  end

  describe "foursquare_return" do
    it 'makes a request for the token using the code, then updates the user FS id and token' do
      user = create(:user)
      sign_in user

      expect( HTTParty ).to receive(:get)
        .with("https://foursquare.com/oauth2/access_token?client_id=#{ Env.foursquare_client_id }&client_secret=#{ Env.foursquare_client_secret }&grant_type=authorization_code&redirect_uri=#{ foursquare_return_oauths_url }&code=12345")
        .and_return( { access_token: 'access-token' }.to_sh )

      allow_any_instance_of( Apis::UserFoursquare ).to receive( :user ).and_return( { response: { user: { id: 1000 } } }.to_sh)

      get :foursquare_return, code: '12345'

      expect( user.reload.foursquare_id ).to eq "1000"

      expect( user.foursquare_access_token ).to eq 'access-token'
    end
  end

  # describe "google" do

  #   it "redirects to an appropriate google endpoint" do
  #     expect(
  #       get :google
  #     ).to redirect_to "https://accounts.google.com/o/oauth2/auth?client_id=#{ Env.google_client_id }&response_type=code&redirect_uri=http://test.host/oauths/google_return"
  #   end
  # end

  # describe "google_return" do
  #   it 'makes a request for the token using the code, then updates the user G id and token' do
  #     user = create(:user)
  #     sign_in user

  #     expect( HTTParty ).to receive(:get)
  #       .with("https://accounts.google.com/o/oauth2/auth?client_id=#{ Env.google_client_id }&client_secret=#{ Env.google_client_secret }&grant_type=authorization_code&redirect_uri=#{ google_return_oauths_url }&scope=https://maps.google.com/feeds/&code=12345")
  #       .and_return( { access_token: 'access-token', refresh_token: 'refresh-token' }.to_sh )

  #     get :google_return, code: '12345'

  #     expect( user.reload.google_access_token ).to eq 'access-token'
  #     expect( user.google_refresh_token ).to eq 'refresh-token'
  #   end
  # end

end