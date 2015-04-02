class Note < BaseModel

  validates_presence_of :body

  is_polymorphic name: :object
  is_polymorphic name: :source, should_validate: false
end
