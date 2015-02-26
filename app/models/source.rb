class Source < ActiveRecord::Base
  belongs_to :object, polymorphic: true
  validates :object_type, :object, :name, :full_url, :base_url, presence: true

  def generic_attrs
    attributes.symbolize_keys.except(:id, :object_id, :object_type, :created_at, :updated_at)
  end
end
