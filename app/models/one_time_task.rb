class OneTimeTask < BaseModel

  is_polymorphic name: :target, should_validate: false
  is_polymorphic name: :agent, should_validate: false

  def self.once(attrs, &block)
    if has?(attrs)
      return false
    else
      run(attrs, &block)
    end
  end

  def self.run(attrs, &block)
    block.call if block_given?
    self.create!(attrs)
    true
  end

  def self.has?(attrs)
    obj = self.where( attrs.to_sh.except(:extras) ).first
    obj ? true : false
  end

end
