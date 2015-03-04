class NpsFeedback < BaseModel

  belongs_to :user
  validates :user_id, :rating, presence: true
  scope :in_last_months, -> (months) { where('created_at > ?', months.months.ago) }

end