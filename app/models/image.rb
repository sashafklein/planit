class Image < BaseModel
  belongs_to :object, polymorphic: true
  belongs_to :uploader, class_name: 'User'
end