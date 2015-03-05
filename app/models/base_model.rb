class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include MetaExt::Base
  include MetaExt::ArrayAccessor
  include MetaExt::JsonAccessor
  include MetaExt::Polymorphism

  # scope :in_last_months, -> (months) { where("#{self.class.to_s.pluralize}.created_at" > ?', months.months.ago) }

end