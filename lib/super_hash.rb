class SuperHash < Hash

  def initialize(hash = {})
    raise "Bad input: #{hash}" unless is_a_or_h?(hash)

    hash.each_pair do |key, val|
      self[key] = compute_value(val)
    end
    self
  end

  def super_fetch(*array, &block)
    hash = dup
    array.flatten.map do |index|
      begin
        hash = hash[index]
      rescue
        return block_given? ? yield(index) : nil
      end
    end
    hash
  end

  def except(*keys)
    hash = dup
    keys.each do |key|
      hash = hash.reject{ |k, v| k == key.to_sym || k == key.to_s }
    end
    hash.to_sh
  end

  def merge(hash)
    recursive_symbolize_keys.to_h.merge( hash.recursive_symbolize_keys ).to_sh
  end

  def [](key)
    super(key.to_sym) || super(key.to_s)
  end

  def []=(key, val)
    if self[key.to_sym]
      super(key.to_sym, val)
    elsif self[key.to_s]
      super(key.to_s, val)
    else
      super(key, val)
    end
  end

  def delete(key)
    super(key.to_sym) || super(key.to_s)
  end

  def slice(*keys)
    recursive_symbolize_keys.to_h.slice( *keys.map(&:to_sym) ).to_sh
  end

  def select_val(&block)
    hash = seed
    each { |k, v| hash[k] = v if yield(v) }
    hash
  end

  def reject_val(&block)
    hash = seed
    each { |k, v| hash[k] = v if !yield(v) }
    hash
  end

  def map_val(&block)
    hash = seed
    each{ |k, v| hash[k] = yield(v) }
    hash
  end

  private

  def method_missing(m, *args, &block)
    return super(m, *args, &block) if args.count > 1

    if is_setter?(m)
      set_val(m, args.first)
    else
      get_val(m, &block)
    end
  end

  def compute_value(val)
    if val.is_a?(Array)
      val.map{ |v| compute_value(v) }
    elsif val.is_a?(Hash)
      SuperHash.new(val)
    else
      val
    end
  end

  def is_a_or_h?(hash)
    hash.is_a?(Array) || hash.is_a?(Hash) || hash.is_a?(SuperHash)
  end

  def is_setter?(sym)
    sym.to_s[-1] == '='
  end

  def set_val(sym, arg)
    prop = sym.to_s[0..-2].to_sym
    self[ prop ] = arg
  end

  def get_val(sym, &block)
    val = self[sym]
    if val.nil?
      block_given? ? yield(sym) : nil
    else
      val
    end
  end

  def seed
    {}.to_sh
  end
end