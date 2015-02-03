module Completers
  class PlaceInProgress

    attr_accessor :attrs, :flags
    delegate *(Place.attribute_keys + [:coordinate, :pinnable, :nearby, :name, :street_address, :foursquare_id]), to: :place

    def initialize(attributes={})
      @attrs = SuperHash.new(defaults.symbolize_keys)
      @flags = []

      attributes.symbolize_keys.each do |key, value|
        set_val(key, value, 'PlaceInProgress', true)
      end
    end

    def update(new_atts, source_class, force=false)
      new_atts.each do |att, val|
        set_val(att, val, source_class, force)
      end
      self
    end

    def place
      Place.new(raw_attrs)
    end

    def val(sym)
      info(sym, :val)
    end

    def source(sym)
      info(sym, :source)
    end

    def set_val(sym, val, source, force=false)
      cleaned_source = clean_source(source)
      if accept?(sym, val, cleaned_source) || force
        if default(sym).is_a? Array
          attrs[sym] = ( attrs[sym] + [{ val: val, source: cleaned_source }] ).uniq
        elsif default(sym).is_a? Hash
          set_hash(sym, val, source)
        else
          attrs[sym] = { val: val, source: cleaned_source }
        end
      end
    end

    def flag(name:, details: nil, info: nil)
      @flags << place.flag(name: name, details: details, info: info)
    end

    def clean_attrs
      attrs.reduce_to_hash{ |k, v| val(k) }.select_val(&:present?)
    end

    private


    def raw_attrs
      attrs.except(:nearby).reduce_to_hash{ |k, v| val(k) }.select_val(&:present?)
    end

    def accept?(sym, val, source)
      ( !val(sym) || source_a_gt_source_b( source, source(sym) ) ) && !val.nil?
    end

    def clean_source(source)
      source.is_a?(Class) ? source.to_s.demodulize : source
    end

    def source_a_gt_source_b(source_a, source_b)
      a_index = source_list.index clean_source(source_a)
      b_index = source_list.index clean_source(source_b)

      raise "Bad source name: #{source_a}" unless a_index

      b_index.nil? || a_index >= b_index
    end

    def source_list
      %w(PlaceInProgress GoogleMaps FoursquareExplore FoursquareRefine Translate)
    end

    def default(sym)
      @as ||= Place.new.attributes
      @as[sym.to_s]
    end

    def defaults
      Place.attribute_keys.inject({}) do |hash, k|
        hash[k] = default(k).nil? ? {} : default(k)
        hash
      end 
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

    def set_hash(sym, val, source)
      val.each do |k, v|
        hash = { val: v, source: source }
        if attrs.super_fetch( sym, k.to_sym ) && attrs.super_fetch( sym, k.to_sym ) != hash
          attrs[sym]["#{k}_#{clean_source(source)}".to_sym] = hash
        else
          attrs[sym][k.to_sym] = hash
        end
      end
    end
  end
end