class TrackHash

  attr_reader :attrs, :defaults, :hierarchy, :_name
  def initialize(defaults, attrs=nil, acceptance_hierarchy=[], name=nil, i=nil)
    @hierarchy, @_name, @_i = acceptance_hierarchy, name, i
    @defaults, @attrs = defaults.symbolize_keys.to_sh, defaults.symbolize_keys.to_sh
    defaults.each{ |k, v| build_accessor(k) }
    set_attrs(attrs) if attrs
  end

  def val(sym)
    info(sym, :val)
  end

  def source(sym)
    info(sym, :source)
  end

  def sources(syms)
    syms.map{ |s| source(s) }
  end

  def set_val(field:, val:, source:, hierarchy_bump: 0)
    source = clean_source(source)

    if accept?(field, val, source, hierarchy_bump)
      if default(field).is_a? Array
        attrs[field] = ( Array(attrs[field]).flatten + [{ val: val, source: source }] ).uniq
      elsif default(field).is_a? Hash
        set_hash(field, val, source)
      else
        attrs[field] = { val: val, source: source }
      end
    end
  end

  def flag(name:, details: nil, info: nil)
    @flags << place.flag(name: name, details: details, info: info)
  end

  def clean_attrs
    attrs.reduce_to_hash{ |k, v| val(k) }.select_val(&:present?)
  end

  def defines?(*atts, all: false)
    defined = vals(atts).select(&:is_defined?)
    all ? vals.all?(&:is_defined?) : vals.any?(&:is_defined?)
  end

  def vals(*atts)
    atts.map{ |a| val(a) }
  end

  def info(sym, type)
    if default(sym).is_a? Array
      attrs[sym].map{ |e| e[type] }.flatten
    elsif default(sym).is_a? Hash
      attrs[sym].reduce_to_hash { |k, v| v[type] }
    else
      attrs.super_fetch( sym, type ) { default(sym) }
    end
  end

  def default(key)
    defaults[key]
  end

  def raw_attrs
    attrs.except(:nearby).reduce_to_hash{ |k, v| val(k) }.select_val(&:present?)
  end

  def clean_attrs
    attrs.reduce_to_hash{ |k, v| val(k) }.select_val(&:present?)
  end

  def defines?(atts, all=false)
    all ? vals.all?(&:is_defined?) : vals.any?(&:is_defined?)
  end

  def type
    _name.gsub(/\d/, '')
  end

  private

  def set_hash(sym, val, source)
    val.each do |k, v|
      hash = { val: v, source: source }
      if attrs.super_fetch( sym, k.to_sym ) && attrs.super_fetch( sym, k.to_sym ) != hash
        attrs[sym]["#{k}_#{source}".to_sym] = hash
      else
        attrs[sym][k.to_sym] = hash
      end
    end
  end

  def build_accessor(field)
    class_eval do
      define_method(field){ val(field) }
      define_method("#{field}=") { |val, src| set_val(field, val, src) }
    end
  end

  def set_attrs(hash)
    hash.each_pair do |key, val|
      set_val(field: key, val: val, source: hierarchy.first)
    end
  end

  def clean_source(source)
    source.is_a?(Class) ? source.to_s.demodulize : source
  end

  def greater_hierarchy?(incoming:, previous:, bump: 0)
    a_index = hierarchy.index clean_source(incoming)
    b_index = hierarchy.index clean_source(previous)

    return false unless a_index

    b_index.nil? || ( a_index + bump ) >= b_index
  end

  def accept?(sym, val, source, hierarchy_bump=0)
    default(sym).is_a_or_h? || ( !val(sym).is_defined? || greater_hierarchy?( incoming: source, previous: source(sym), bump: hierarchy_bump ) ) && val.is_defined?
  end
end