class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include MetaExt::BaseExt
  include MetaExt::ArrayAccessor
  include MetaExt::JsonAccessor
  include MetaExt::Polymorphism
  include MetaExt::Searchable

  # scope :in_last_months, -> (months) { where("#{self.class.to_s.pluralize}.created_at" > ?', months.months.ago) }

  has_many_polymorphic table: :one_time_tasks, name: :target

end