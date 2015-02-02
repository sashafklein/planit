class Flag < BaseModel
  belongs_to :object, polymorphic: true

  json_accessor :info

  def description
    [name, details].compact.join(" - ")
  end
end
