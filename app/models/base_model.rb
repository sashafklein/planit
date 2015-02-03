class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  include MetaExt::Base
  include MetaExt::ArrayAccessor
  include MetaExt::JsonAccessor
end