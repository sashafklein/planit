module ActiveRecord
  module ClassInfo
    def attribute_keys
      column_names.reject do |name| 
        name.include?('id') || 
          %w(updated_at created_at).include?(name)
      end.map(&:to_sym)
    end
  end
end