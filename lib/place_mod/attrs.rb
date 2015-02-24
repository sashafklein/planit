module PlaceMod
  class Attrs

    attr_reader :attrs, :flags
    def initialize(attrs)
      @attrs = attrs.symbolize_keys.to_sh
      @flags = []
    end

    def normalize
      pluralize_singular_array_attrs
      prioritize_latinate_names
      encode_characters_in_names
      format_and_validate_lat_lon
      normalize_json_attrs
      clean_nearby
      set_feature_type

      @attrs = attrs.reject_val(&:nil?)
      found = PlaceMod::Finder.new(attrs).find!
      @attrs = attrs.merge( found.attributes.symbolize_keys.to_sh.reject_val(&:nil?) ) if found.persisted?
      @attrs
    end

    def set_photos
      photo_array = Array( attrs.delete(:images) ).flatten
      photo_array.map{ |a| Image.new({ url: a[:url], source_url: a[:source], source: a[:credit] }) }
    end

    private

    def pluralize_singular_array_attrs
      [:name, :street_address, :category].each do |singular|
        plural = singular.to_s.pluralize.to_sym
        attrs[plural] = Array( attrs.delete(plural) ).flatten + Array( attrs.delete(singular)).flatten
      end
    end

    def prioritize_latinate_names
      attrs.names = attrs.names.select(&:latinate?) + attrs.names.select(&:non_latinate?)
    end

    def encode_characters_in_names
      attrs.names = attrs.names.map{ |s| s.decode_characters }
    end

    def format_and_validate_lat_lon
      [:lat, :lon].each{ |att| attrs[att] = attrs.delete(att).try(:to_f) }
      validate_or_nullify_lat_lon!
    end

    def normalize_json_attrs
      attrs[:phones] = normalize_phones
      attrs[:hours] = normalized_hours(attrs[:hours])
      attrs[:extra] = normalize_extra
    end

    def validate_or_nullify_lat_lon!
      return unless attrs.lat && attrs.lon
      attrs.lat && attrs.lon && timezone = Timezone::Zone.new({latlon: [attrs.lat, attrs.lon]})
      attrs.timezone_string = timezone.zone
    rescue
      flag({ name: "Invalid LatLon found", details: "Cleared out LatLon in PlaceMod::Attrs", info: { old: { lat: attrs.lat, lon: attrs.lon} } })
      attrs.lat, attrs.lon = nil
      false
    end

    def flag(hash)
      @flags << Flag.new(hash)
    end

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
      
      attrs[:extra] = { misc: attrs[:extra] }.to_sh if !attrs[:extra].is_a? Hash
      
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

    def clean_nearby
      attrs.nearby = attrs.nearby.gsub(/<.*>/, '') if attrs.nearby
    end

    def set_feature_type
      attrs[:feature_type] ||= PlaceMod::FeatureType.new(attrs, attrs.nearby).number
    end
  end
end