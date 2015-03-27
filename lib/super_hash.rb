class SuperHash < Hash

  include SuperBase

  def initialize(hash = {})
    raise "Bad input: #{hash}" unless hash.is_a_or_h?

    hash.each_pair do |key, val|
      if val.is_a_or_h?
        self[key] = val.to_super
      else
        self[key] = val
      end
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
    reject{ |k, v| keys.map(&:to_sym).include?(k.to_sym) }.to_sh
  end

  def only(*keys)
    select{ |k, v| keys.map(&:to_sym).include?(k.to_sym) }.to_sh
  end

  def only(*keys)
    hash = {}
    keys.each do |key|
      hash[key.to_sym] = self[key] if self[key]
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

  def to_yaml
    almost_there = to_h.to_yaml
    almost_ther.gsub(/([\s|^]*):(\S+:)([\s|$]+)/){ "#{$1}#{$2}#{$3}" }.gsub("---\n", '').gsub(/(\s+)-/){ "#{$1}  -" }.gsub('  ', ' ')
  end

  def to_h
    new_hash = {}
    super.each_pair do |k, v|
      new_hash[k] = v.is_a_or_h? ? v.try(:to_normal) || v : v
    end
    new_hash
  end


  private

  def method_missing(m, *args, &block)
    return super(m, *args, &block) if self.class.superclass.new.respond_to?(m)

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