class SourceParser

  delegate :scheme, :hostname, :path, :query, to: :url

  attr_accessor :url
  def initialize(url)
    raise "Can't parse nil URL" if url.nil?
    @url = URI(url)
  end

  def trimmed
    return name unless real?
    "#{ base }#{ path }#{ relevant_querystring }"
  end

  def base
    return name unless real?
    "#{ scheme }://#{ hostname }"
  end

  def full
    return name unless real?
    url.to_s
  end

  def name
    found_name = name_hash[domain.to_sym]
    Flag.create!(name: 'Unknown Source Name', info: { url: url.to_s } ) unless found_name
    found_name || domain.capitalize
  end

  private

  def domain
    s = hostname.split(".")
    s.length > 2 ? s[1] : s[0]
  end

  def relevant_querystring
    return unless query.present?
    qstring = query.split("&").select{ |pair| allowable_params.include?( pair.split("=").first ) }.join("&")
    qstring.present? ? "?#{ qstring }" : nil
  end


  def allowable_params
    %w( code q query name lat lon lng pagewanted )
  end

  def name_hash
    { 
      nytimes: "New York Times",
      huffpo: "Huffington Post",
      stay: 'Stay',
      afar: 'Afar',
      airbnb: 'AirBNB',
      booking: 'Booking',
      fodors: 'Fodors',
      frommers: 'Frommers',
      googlemaps: 'Google Maps',
      huffingtonpost: 'Huffington Post',
      lonelyplanet: 'Lonely Planet',
      nationalgeographic: 'National Geographic',
      travelandleisure: 'Travel and Leisure',
      tripadvisor: 'Trip Advisor',
      yelp: 'Yelp',
      kml: 'KML'
    }
  end

  def real?
    !%w(kml email).include? domain
  end
end