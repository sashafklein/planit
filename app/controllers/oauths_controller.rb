class OauthsController < ApplicationController
  
  def foursquare
    save_back_path!
    path = qs_path("https://foursquare.com/oauth2/authenticate", { 
      client_id: Env.foursquare_client_id, 
      response_type: 'code', 
      redirect_uri: foursquare_return_oauths_url
    })

    redirect_to path
  end

  def foursquare_return
    path = qs_path "https://foursquare.com/oauth2/access_token", { 
      client_id: Env.foursquare_client_id,
      client_secret: Env.foursquare_client_secret,
      grant_type: 'authorization_code',
      redirect_uri: foursquare_return_oauths_url,
      code: params[:code]
    }

    token = HTTParty.get(path).to_sh.access_token
    foursquare_id = Apis::UserFoursquare.new({ foursquare_access_token: token }.to_sh).user.super_fetch(:response, :user, :id)

    current_user.update_attributes!(foursquare_access_token: token, foursquare_id: foursquare_id)

    redirect_to get_back_path! || root_path
  end
  
  # def google
  #   save_back_path!
  #   path = qs_path("https://accounts.google.com/o/oauth2/auth", { 
  #     client_id: Env.google_client_id, 
  #     response_type: 'code', 
  #     redirect_uri: google_return_oauths_url
  #   })

  #   redirect_to path
  # end

  # def google_return
  #   path = qs_path "https://accounts.google.com/o/oauth2/auth", { 
  #     client_id: Env.google_client_id,
  #     client_secret: Env.google_client_secret,
  #     grant_type: 'authorization_code',
  #     redirect_uri: google_return_oauths_url,
  #     scope: 'https://maps.google.com/feeds/', # this needs to be adjusted/fixed
  #     code: params[:code]
  #   }

  #   response = HTTParty.get(path).to_sh

  #   current_user.update_attributes!(google_access_token: response.access_token, google_refresh_token: response.refresh_token)

  #   redirect_to get_back_path! || root_path
  # end

end