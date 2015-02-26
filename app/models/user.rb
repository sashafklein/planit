class User < BaseModel

  after_create :notify_signup

  validates :first_name, :last_name, presence: true

  enum role: { pending: 0, member: 1, admin: 2 }

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :plans
  has_many :marks
  has_many :nps_feedbacks
  has_many :page_feedbacks
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
    {
      name: source,
      items: { marks: source_marks },
      permission: 'public',
      slug: source_marks.places.ids.join("+"),
    }.to_sh 
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

  def tags
    marks.all_tags
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

  def years_on_planit
    (Time.now().to_f - created_at.to_f) / (60*60*24*365.25)
  end

  private

  def notify_signup
    UserMailer.notify_of_signup(self).deliver_later
  end
  
end