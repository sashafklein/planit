class PlaceOption < BaseModel

  belongs_to :mark
  validates :mark, :mark_id, presence: :true

  def place
    Place.new( attributes.except("mark_id") )
  end

  def self.place
    Place
  end

  delegate *Place.instance_methods(false), to: :place

  class << self
    delegate *Place.methods(false), to: :place
  end
end