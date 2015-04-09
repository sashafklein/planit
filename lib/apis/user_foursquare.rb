module Apis
  class UserFoursquare
    
    attr_accessor :values, :user
    def initialize(user)
      raise "No access token" unless user.foursquare_access_token
      @user = user
      @values = defaults.merge({ oauth_token: user.foursquare_access_token }).to_sh
    end

    def lists
      get "#{base_path}/users/#{foursquare_user_id}/lists?#{ querystring(:v, :oauth_token) }"
    end

    def list(list_id)
      list_id = list_id.include?(foursquare_user_id) ? list_id : "#{foursquare_user_id}/#{list_id}"
      get "#{base_path}/lists/#{list_id}?#{querystring(:v, :oauth_token)}"
    end

    def add_to_list(list_name, venue_id)
      post "#{base_path}/lists/#{list_name}/addItem?#{querystring(:v, :oauth_token)}&venueId=#{venue_id}"
    end

    def user
      get "#{base_path}/users/self?#{ querystring(:v, :oauth_token) }" 
    end

    private

    def foursquare_user_id
      @foursquare_user_id ||= user.foursquare_id || user.super_fetch(:response, :user, :id)
    end

    def post(request)
      HTTParty.post(request).to_sh
    end

    def get(request)
      HTTParty.get(request).to_sh
    end

    def base_path
      'https://api.foursquare.com/v2'
    end

    def defaults
      { v: Env.foursquare_version_number || '20140806' }
    end

    def querystring(*take)
      values.only(*take).map{ |k, v| "#{k}=#{v}" }.join("&")
    end
  end
end