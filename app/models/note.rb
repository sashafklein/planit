class Note < BaseModel
  is_polymorphic name: :object
  is_polymorphic name: :source, should_validate: false
end
