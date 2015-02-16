class User < BaseModel

  enum role: { member: 0, admin: 1 }

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :plans
  has_many :marks
  has_many :items, through: :marks

  extend FriendlyId
  friendly_id :name, use: :slugged

  def name
    "#{first_name} #{last_name}"
  end

  def icon
    false
  end

  def items_and_marks
    [items, marks].flatten
  end

  def items_in_last_month?
    items.where('items.updated_at > ?', 1.month.ago).present? || items.where('items.created_at > ?', 1.month.ago).present? 
  end

  def marks_in_last_month?
    marks.where('updated_at > ?', 1.month.ago).present? || marks.where('created_at > ?', 1.month.ago).present? 
  end

  def bucket_plan
    bucket = plans.where(bucket: true).first_or_create(name: "#{name} Bucket")
  end

  # USER GUIDES LOGIC

  def all_sources
    User.first.marks.map(&:source).compact.uniq
  end

  def planify_source_guide(source, source_marks)
    pseudo_guide = {}
    pseudo_guide.name = source
    pseudo_guide.items.marks = source_marks
    pseudo_guide.permission = 'public'
    pseudo_guide.slug = source_marks.places.ids.join('+')
    return pseudo_guide
  end

  def chunkify_source_marks_by_tag(source, source_marks, min_threshold=8)
    chunked_array = []
    long_tail = []
    array_of_other_tags = []
    # array_of_other_tags = source_marks.select{(marks) -> !marks.map('tag').contains(source)}.map(&:tag).compact.uniq
    return [{name: source, marks: source_marks}] unless array_of_other_tags.present?
    array_of_other_tags.each do |tag|
      chunked_marks = source_marks.where(tag: tag)
      if chunked_marks.length < min_threshold
        long_tail = long_tail + chunked_marks
      else
        chunked_array << {name: tag, marks: chunked_marks}
      end
    end
    chunked_array << { name: source, marks: long_tail } if long_tail.present?
    return chunked_array
  end

  def source_guides(array_of_sources, max_threshold)
    array_of_guides = []
    array_of_sources.each do |source|
      source_marks = marks.where(source: source)
      if source_marks.length < max_threshold
        array_of_guides << planify_source_guide(source, source_marks)
      else
        chunkify_source_marks_by_tag(source, source_marks).each do |chunked_source|
          array_of_guides << planify_source_guide(chunked_source.name, chunked_source.marks)
        end
      end
    end
    return array_of_guides
  end

  def guides
    (plans + source_guides(all_sources, 25))
    # for each plan, get average_updated for items.marks, then sort descending
  end
  
end