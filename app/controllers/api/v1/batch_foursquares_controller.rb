class Api::V1::BatchFoursquaresController < ApiController
  
  require 'deep_struct'

  def venues
    csv = params[:csv]
    csv.split("\n").map do |row|
      row_struct = struct(hash(row))
      binding.pry
      venue = RestClient.get venue_path u(split[0]), u(split[1])
      photo = RestClient.get photo_path venue
      yamlify(venue, row, photo)
    end
  end

  private

  def token 
    "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
  end

  def base_path
    "https://api.foursquare.com/v2/venues/"
  end

  def venue_path(destination, locale)
    "#{base_path}explore?query=#{destination}&near=#{locale}&oauth_token=#{token}"
  end

  def photo_path(venue)
    "#{base_path}#{venue['id']}/photos?oauth_token=#{token}" 
  end

  def yamlify(venue, row, photo)
    row = struct(row)
    [
      "\n      -",
      "  items:",
      "    -",
      "      name: #{row.destination}",
      "      local_name: #{venue.name}",
      "      notes: ",
      "      address: #{venue.location.try(:address)}, #{venue.location.try(:city)}, #{venue.location.try(:state)}",
      "      phone: #{venue.contact.phone}",
      "      street_address: #{venue.location.try(:address)}",
      "      city: #{venue.location.try(:city)}",
      "      state: #{venue.location.try(:state)}",
      "      country: #{venue.location.try(:country)}",
      "      cross_street: #{venue.location.try(:crossStreet)}",
      "      category: #{venue.categories[0].try(:name)}",
      "      price_tier: #{venue.price.try(:tier)}",
      "      rating: #{venue.rating}",
      "      rating_signals: #{venue.ratingSignals}",
      "      date_of_API_pull: #{Date.today}",
      "      lat: #{venue.location.try(:lat)}",
      "      lon: #{venue.location.try(:lng)}",
      "      website: #{venue.url}",
      "      tab_image: #{photo || ''}",
      "      source: Foursquare",
      "      source_url: http://foursquare.com/v/#{venue.id}",
      "      travel_type: #{row.travel || ''}",
      "      has_tab: true",
      "      lodging: #{row.lodging || ''}",
      "      time_of_day: ",
      "      parent_day: #{row.day || ''}",
      "      parent_cluster: 1"
    ].join("\n      ").gsub('undefined', '')
  end

  def u(string)
    string.gsub(" ", '%20')
  end

  def hash(row)
    { destination: row[0], locale: row[1], day: row [2], lodging: row[3], travel: row[4] }
  end

  def struct(hash)
    DeepStruct.new(hash)
  end
end