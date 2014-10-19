require 'json'
require 'uri'

class FourSquareCompleter

  attr_accessor :params
  def initialize(params)
    @params = params
  end

  def complete!
    return params if complete? || !sufficient_to_fetch?
    
    fetch
    params
  end

  private

  def sufficient_to_fetch?
    (params[:locality] || (params[:lat] && params[:lon])) && params[:name]
  end

  def complete?
    keys.all?{ |k| params[k] }
  end

  def keys
    %w(name street_address locality country phone tab_image has_tab image_credit source source_url lat lon)
  end

  def fetch
    venue = JSON.parse(`curl '#{full_url}'`)['response']['groups'][0]['items'][0]['venue']
    merge(venue)
    getPhoto(venue)
  rescue
    params
  end

  def locality
    if params[:locality] 
      near = "near=#{params[:locality]}"
    else
      near = "ll=#{params[:lat]},#{params[:lon]}"
    end
    URI.escape near
  end

  def query
    URI.escape( params[:name] || params[:street_address] )
  end

  def full_url
    "#{base_url}?#{locality}&query=#{query}&oauth_token=#{auth_token}&venuePhotos=1"
  end

  def base_url
    'https://api.foursquare.com/v2/venues/explore'
  end

  def auth_token
    "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  end

  def merge(venue)
    params[:name] ||= venue['name']
    params[:phone] ||= venue['contact']['phone']
    params[:street_address] ||= venue['location']['address']
    params[:lat] ||= venue['location']['lat']
    params[:lon] ||= venue['location']['lng']
    params[:country] ||= venue['location']['country']
    params[:state] ||= venue['location']['state']
    params[:city] ||= venue['location']['city']
    params[:category] ||= venue['categories'][0]['name']
    params[:meal] ||= params[:category].present? && params[:category].downcase.include?('restaurant')
    params[:lodging] ||= params[:category].present? && params[:category].downcase.include?('hotel')
    params
  end

  def getPhoto(venue)
    photo = venue['featuredPhotos']['items'][0]
    params[:photo] ||= [photo['prefix'], photo['suffix']].join("200x200")
  rescue
    nil
  end
end