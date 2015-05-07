class LocationSearch < BaseModel
  has_one :location
  has_one :user
end