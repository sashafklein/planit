class User < ActiveRecord::Base

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

  def recent_activity_dates
    
  end

  def recent_updates
    recent_marks = marks.where('updated_at > ?', 1.month.ago).order('updated_at DESC')
    recent_plans = plans.where('updated_at > ?', 1.month.ago).order('updated_at DESC')
    recent_items = items.where('items.updated_at > ?', 1.month.ago).order('items.updated_at DESC')
    [recent_marks + recent_plans + recent_items].flatten.sort_by{ |i| i.updated_at }.reverse
  end

  def recent_creates
    recent_marks = marks.where('created_at > ?', 1.month.ago).order('created_at DESC')
    recent_plans = plans.where('created_at > ?', 1.month.ago).order('created_at DESC')
    recent_items = items.where('items.created_at > ?', 1.month.ago).order('items.created_at DESC')
    [recent_marks + recent_plans + recent_items].flatten.sort_by{ |i| i.created_at }.reverse
  end

  def bucket_plan
    bucket = plans.where(bucket: true).first_or_create(name: "#{name} Bucket")
  end
end
