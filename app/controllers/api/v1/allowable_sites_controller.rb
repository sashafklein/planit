class Api::V1::AllowableSitesController < ApiController
  
  def test
    if params[:url] && gatekeep(params[:url])
      render json: { success: true }
    else
      return error(status: 406, message: "Not Acceptable")
    end
  end

  private

  def acceptable_hosts
    [
      # BUILT
      "afar",
      "airbnb",
      "booking",
      "eater",
      "fodors",
      "frommers",
      "lonelyplanet",
      "nationalgeographic",
      "nytimes",
      "stay",
      "travelandleisure",
      "tripadvisor",
      "yelp",
      # NOT BUILT YET
      "trippy",
      "gogobot",
      "foursquare",
      "timeout",
      "tablethotels",
      "roughguide",
      "concierge",
      "jgblackbook",
      "gayot",
      "gourmet",
      "sosh",
      "tripexpert",
      "everplaces",
      "tripcipe",
      "cntraveler",
      "bonappetit",
      "stumbleupon",
      "pinterest",
    ].join("|")
  end

  def acceptable_url_strings
    [
      # BUILT
      # NOT BUILT YET
      "maps.google.com/\\?q=",
      "www.google.com/maps\\?",
      "www.google.com/maps/place/",
      "www.facebook.com/pages/",
    ].join("|")
  end

  def gatekeep(url_to_parse)
    if match = url_to_parse.scan(/\A(?:http[s]?[:]\/\/)?(?:[a-z0-9]*\.)?(?:[a-z]*\.)?(#{acceptable_hosts})\.(?:[a-z]{2}\.[a-z]{2}|[a-z]{2}|[a-z]{3})(?:\/.*\Z|\/\Z|\Z)/).flatten.first
      return true
    elsif match = url_to_parse.scan(/\A(?:http[s]?[:]\/\/)?(#{acceptable_url_strings})/).flatten.first
      return true
    end
  end

end