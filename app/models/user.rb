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
  
end