# Hash with indifferent and method access, and a super_fetch method which
# can deep-fetch with an error block that can take the key as an argument.

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
    hash
  end

  def merge(hash)
    self.class.new( self.recursive_symbolize_keys.merge(hash.recursive_symbolize_keys) )
  end

  def [](key)
    super(key.to_s) || super(key.to_sym)
  end

  def []=(key, val)
    if [key.to_s]
      super(key.to_s, val)
    else [key.to_sym]
      super(key.to_sym, val)
    end
  end

  private

  def method_missing(m, *args, &block)
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
    self[ sym.to_s[0..-2].to_sym ] = arg
    self[prop]
  end

  def get_val(sym, &block)
    val = self[sym]
    if val.nil?
      block_given? ? yield(sym) : nil
    else
      val
    end
  end
end