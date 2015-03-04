class PageFeedback < BaseModel

  belongs_to :user
  belongs_to :nps_feedback
  scope :in_last_months, -> (months) { where('created_at > ?', months.months.ago) }

  def self.details(hash)
    hash.inject([]) { |ar, hash| ar << "#{hash.first.to_s.capitalize}: #{hash.last}"; ar }.join("\n")
  end
end