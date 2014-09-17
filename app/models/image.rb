class Image < ActiveRecord::Base
  belongs_to :object, polymorphic: true
  belongs_to :uploader, class_name: 'User'
end