module Apis
  class Foursquare

    def explore(params={})
      HTTParty.get "#{ base_url }/venues/explore?#{ querystring(params) }"
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
      }
    end

  end
end