class Source < BaseModel
  is_polymorphic
  has_many_polymorphic table: :notes, name: :source
  validates :name, :full_url, :base_url, presence: true

  scope :for_url, -> (url) { where( trimmed_url: SourceParser.new(url).trimmed ) }
  scope :for_url_and_type, -> (url, o_type) { for_url(url).where(object_type: o_type) }
  
  def generic_attrs
    attributes.symbolize_keys.except(:id, :object_id, :object_type, :created_at, :updated_at)
  end

  def path_only_url
    trimmed_url.gsub(/((?:http[s]?[:]\/\/)?(?:www[.])?)/, '') if trimmed_url
  end

end
