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

end