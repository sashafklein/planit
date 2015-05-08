class Location < BaseModel
  has_many :location_searches
  has_many :users, through: :location_searches
  has_many :plans, through: :plan_locations
  has_many :plan_locations, dependent: :destroy
end