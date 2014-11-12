module ActiveRecord
  module MetaExt
      
    # CLASS METHODS
    module ClassMethods
      def attribute_keys
        column_names.reject do |name| 
          name.include?('id') || 
            %w(updated_at created_at).include?(name)
        end.map(&:to_sym)
      end

      def validate!
        include ActiveModel::Validations
        validates_with("#{name}Validator".constantize)
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # INSTANCE METHODS
    def complete?
      self.class.attribute_keys.all?{ |k| send(k) == false || send(k).present? } 
    end
  end
end