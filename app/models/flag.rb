class Flag < ActiveRecord::Base
  belongs_to :object, polymorphic: true

  def info
    self[:info].class == Hash ? self[:info].to_sh : self[:info]
  end

  def description
    [name, details].compact.join(" - ")
  end
end
