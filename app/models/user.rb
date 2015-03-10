class User < BaseModel

  validates :first_name, :last_name, presence: true

  enum role: { pending: 0, member: 1, admin: 2 }

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :plans
  has_many :marks
  has_many :flags, as: :object
  has_many :nps_feedbacks
  has_many :page_feedbacks
  has_many :items, through: :marks

  extend FriendlyId
  friendly_id :name, use: :slugged

  def name
    [first_name, last_name].compact.join(" ")
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

  def marks_to_review
    Mark.where( place_id: nil )
  end

  def messages
    marks_to_review.count
  end

  def save_as(status)
    password = Devise.friendly_token.first(8)
    update_attributes({ password: password, password_confirmation: password, role: status })
    notify_signup(password) if self.persisted?
    return self
  end

  # USER GUIDES LOGIC

  def years_on_planit
    (Time.now().to_f - created_at.to_f) / (60*60*24*365.25)
  end

  private

  def notify_signup(password)
    AdminMailer.notify_of_signup(self).deliver_later
    UserMailer.welcome_waitlist(self).deliver_later if pending?
    UserMailer.welcome_invited(self, password).deliver_later if member?
  end
  
end