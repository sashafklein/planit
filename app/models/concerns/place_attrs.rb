class PlaceAttrs

  attr_reader :attrs
  def initialize(attrs)
    @attrs = attrs.symbolize_keys.to_sh
  end

  def normalize
    [:name, :street_address, :category].each do |singular|
      plural = singular.to_s.pluralize.to_sym
      attrs[plural] = Array( attrs.delete(plural) ).flatten + Array( attrs.delete(singular)).flatten
    end

    attrs[:names] = attrs[:names].select(&:latinate?) + attrs[:names].select(&:non_latinate?)
    
    [:lat, :lon].each{ |att| attrs[att] = attrs.delete(att).try(:to_f) }

    attrs[:phones] = normalize_phones
    attrs[:hours] = normalized_hours(attrs[:hours])
    attrs[:extra] = normalize_extra

    found = Services::PlaceFinder.new(attrs).find!
    @attrs = attrs.merge( found.attributes.symbolize_keys.reject{ |k,v| v.nil? }.to_sh ) if found.persisted?
    @attrs
  end

  def set_photos
    photo_array = Array( attrs.delete(:images) ).flatten
    photo_array.map{ |a| Image.new({ url: a[:url], source_url: a[:source], source: a[:credit] }) }
  end

  private

  def extra_attrs
    attrs.except(*Place.attribute_keys + [:nearby, :images])
  end

  def normalize_phones
    array = []
    [:phones, :phone].each do |sym|
      val = attrs.delete(sym)
      array += val.values if val.is_a?(Hash)
      array += Array(val) if val.is_a?(String) || val.is_a?(Array)
    end
    attrs[:phones] = array.flatten
  end

  def normalize_extra
    attrs[:extra] ||= {}.to_sh
    if !attrs[:extra].is_a? Hash
      attrs[:extra] = { misc: attrs[:extra] }.to_sh
    end

    extra_attrs.each { |k, _| attrs[:extra][k] = attrs.delete(k) }
    attrs[:extra]
  end

  def normalized_hours(hours)
    normalized = {}
    (hours || {}).each do |k, v|
      normalized[k.to_s.downcase] = v.stringify_keys
    end
    Services::TimeConverter.convert_hours(normalized)
  end
end