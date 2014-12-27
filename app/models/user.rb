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

  def recent_plan_activity?(date)
    return true unless plans.present?
    return false
  end

  def recent_pin_activity?(date)
    return false unless items.where('items.updated_at >= ?', date.to_time).where('items.updated_at < ?', (date.to_time + 86400) ).present? || marks.where('updated_at >= ?', date.to_time).where('updated_at < ?', (date.to_time + 86400) ).present?
    return true
  end

  def recent_items
    recent_items = items.where('items.updated_at > ?', 1.month.ago).order('items.updated_at DESC')
  end

  def recent_marks
    recent_marks = marks.where('updated_at > ?', 1.month.ago).order('updated_at DESC')
  end

  def recent_plans
    recent_plans = plans.order('updated_at DESC')
  end

  def bucket_plan
    bucket = plans.where(bucket: true).first_or_create(name: "#{name} Bucket")
  end
end
