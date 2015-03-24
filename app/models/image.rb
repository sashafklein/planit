class Image < BaseModel
  is_polymorphic name: :imageable
  belongs_to :uploader, class_name: 'User'
  validates :url, :source, presence: true
  validate :is_secure?

  def self.trim_dead!
    where('updated_at < ?', 2.weeks.ago).find_each do |image|
      begin
        if open(image.url)
          image.touch
          true
        end
      rescue
        image.destroy
      end
    end
  end

  def save_https!
    if preexisting = exists?
      return preexisting if preexisting.imageable == imageable
      Image.create!(imageable: imageable, url: preexisting.url, source: preexisting.source, source_url: preexisting.source_url, subtitle: preexisting.subtitle, uploader_id: preexisting.uploader_id)
    else
      self.url = https(url) if !is_secure?
      save_modified!
    end
  end

  def exists?(object=nil)
    if object
      object.images.find_by(url: https(url))
    else
      Image.find_by(url: https(url))
    end
  end

  private

  def https(url)
    url.gsub('http://', 'https://')
  end

  def is_secure?
    url.include?("https://")
  end

  def save_modified!
    save! if open(url)
    self
  rescue
    destroy
    nil
  end
end

