class OneTimeTask < BaseModel

  is_polymorphic name: :target, should_validate: false
  is_polymorphic name: :agent, should_validate: false

  def self.execute(attrs, &block)
    if has?(attrs)
      return false
    else
      block.call if block_given?
      self.create!(attrs)
      return true
    end
  end

  def self.has?(attrs)
    obj = self.where( attrs.to_sh.except(:extras) ).first
    obj ? true : false
  end

end
