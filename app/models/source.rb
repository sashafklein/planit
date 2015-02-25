class Source < ActiveRecord::Base
  belongs_to :object, polymorphic: true
  validates :object_type, :object, :name, :full_url, :base_url, presence: true
end
