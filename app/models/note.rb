class Note < BaseModel

  validates_presence_of :body

  is_polymorphic name: :obj
  is_polymorphic name: :source, should_validate: false
end
