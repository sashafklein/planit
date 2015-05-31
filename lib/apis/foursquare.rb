module Apis
  class Foursquare

    def explore(params={})
      get "#{ base_url }/venues/explore?#{ querystring(params) }"
    end

    def lists(user_id)
      get "#{ base_url }/users/#{ user_id }/lists?#{ querystring }"
    end

    def list(user_id, list_id=nil)
      list_id = list_id && list_id.include?(user_id.to_s) ? list_id : [user_id, list_id].compact.join('/')
      get "#{ base_url }/lists/#{ list_id }?#{ querystring }"
    end

    def user(user_id)
      get "#{ base_url }/users/#{ user_id }?#{ querystring }"
    end

    def venue(venue_id)
      get "#{ base_url }/venues/#{ venue_id }?#{ querystring }"
    end

    private

    def querystring(vals={})
      vals.merge(auth).inject([]){ |a, pair| a << "#{pair.first}=#{pair.last}"; a }.join("&")
    end

    def base_url
      'https://api.foursquare.com/v2/'
    end

    def auth
      {
        client_id: Env.foursquare_client_id,
        client_secret: Env.foursquare_client_secret,
        v: Env.foursquare_version_number
      }.inject([]){ |a, pair| a << "#{pair.first}=#{pair.last}"; a }.join("&")
    end

    def get(request)
      HTTParty.get(request).to_sh
    end
  end
end