require 'spec_helper'

describe Mark do
  
end

def full_params
  place_params.merge(photo_params).merge(mark_params)
end

def place_params
  {
    lat: 37.74422249388305,
    lon: -122.4352317663816,
    name: "Contigo",
    phone: "4152850250",
    street_address: "1320 Castro St",
    country: "United States",
    state: "CA",
    city: "San Francisco",
  }
end

def photo_params
  { photo: "https://irs3.4sqi.net/img/general/#{Completers::FoursquareExploreVenue::IMAGE_SIZE}/2261_a2HV5M7fSEIO1oiL0DHbvHMGdJ3xHEozUVUY0U5w0ag.jpg" }
end

def mark_params
  {
    category: "Spanish Restaurant",
    meal: true,
    lodging: false
  }
end