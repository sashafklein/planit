class PageFeedback < BaseModel

  belongs_to :user
  scope :in_last_months, -> (months) { where('created_at > ?', months.months.ago) }

end