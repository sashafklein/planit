class Image < BaseModel
  is_polymorphic name: :imageable
  belongs_to :uploader, class_name: 'User'
  validates :url, :source, presence: true
end

