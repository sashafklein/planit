class ObjectLocation < BaseModel
  belongs_to :location
  belongs_to :obj, polymorphic: true
end
