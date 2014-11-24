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

      def none
        where('1=2')
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # INSTANCE METHODS
    def complete?
      self.class.attribute_keys.all?{ |k| read_attribute(k) == false || read_attribute(k).present? } 
    end

    def atts(*to_slice)
      return attributes unless to_slice.length
      attributes.symbolize_keys.slice(*Array(to_slice).map(&:to_sym))
    end

    def merge(other, exceptions=[])
      return self if other.atts(*other.class.attribute_keys) == atts(*other.class.attribute_keys)

      cleaned( array_attributes, exceptions ).each do |att, val|
        write_attribute att, ( Array(val) + Array(other.read_attribute(att)) )
      end

      cleaned( hash_attributes, exceptions ).each do |att, val|
        write_attribute att, Hash(other.read_attribute(att)).merge( Hash( val ) )
      end

      cleaned( other_attributes, exceptions ).each do |att, val|
        write_attribute( att, other.read_attribute(att) ) unless has?( read_attribute(att) )
      end

      self
    end

    def has?(att)
      att.present? || att == false
    end

    def array_attributes
      attributes.select{ |k, v| v.is_a? Array }
    end

    def hash_attributes
      attributes.select{ |k, v| v.is_a? Hash }
    end

    def other_attributes
      attributes.select{ |k, v| !v.is_a?(Hash) && !v.is_a?(Array) }
    end

    def uniqify_array_attrs
      array_attributes.keys.each do |att|
        write_attribute(att, read_attribute(att).compact.uniq) if send("#{att}_changed?")
      end
    end

    private

    def cleaned(attrs, exceptions)
      attrs.reject{ |k, v| exceptions.include?(k) }
    end
  end
end