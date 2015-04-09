require 'rails_helper'

describe OauthsController do
  describe "foursquare" do
    describe "foursquare" do

      before do 
        allow(Env).to receive(:foursquare_client_id).and_return '12345'
        allow(Env).to receive(:foursquare_client_secret).and_return '56789'
      end

      xit "redirects to an appropriate foursquare endpoint" do
        expect{ 
          get :foursquare
        }.to redirect_to "https://foursquare.com/oauth2/authenticate?client_id=12345&response_type=code&redirect_uri=test"
      end
    end
  end
end