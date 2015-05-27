module MetaExt
  module BaseExt

    module ClassMethods

      def metaclass
        class << self; self; end
      end
      
      def attribute_keys(reject_ids: true)
        column_names.reject do |name|
          if reject_ids
            name == 'id' || 
            ActiveRecord::Base.connection.tables.any?{ |t| name == "#{ t.singularize }_id" } ||
            %w(updated_at created_at).include?(name)
          else
            %w(updated_at created_at).include?(name)
          end
        end.map(&:to_sym)
      end

      def validate!
        include ActiveModel::Validations
        validates_with("#{name}Validator".constantize)
      end

      def none
        where('1=2')
      end

      def boolean_accessor(*symbols)
        symbols.each do |symbol|

          metaclass.instance_eval do 
            define_method(symbol) do
              where("#{table_name}.#{symbol} = ?", true)
            end

            define_method("not_#{symbol}") do
              where("#{table_name}.#{symbol} = ?", false)
            end
          end

        end
      end

      def correct_data_types(attr_hash)
        new_atts = {}
        attr_hash.each do |k, v|
          new_atts[k] = correct_data_type(k, v)
        end
        new_atts
      end

      def correct_data_type(k, v)
        c = columns_hash[k.to_s]
        t = c.type == :string ? (c.default == '{}' ? :array : :string) : c.type if c
        c ? v.to_class( t ) : v
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def flag(name:, details: nil, info: {})
      flags.where(name: name, details: details).first_or_initialize(info: info)
    end

    def flag!(name:, details: nil, info: {})
      flag(name: name, details: details, info: info).save!
    end
    def complete?
      self.class.attribute_keys.all?{ |k| read_attribute(k) == false || read_attribute(k).present? } 
    end

    def atts(*to_slice)
      return attributes unless to_slice.length
      attributes.symbolize_keys.to_sh.only( *Array(to_slice) )
    end

    def atts_except(*exclude)
      return attributes.to_sh unless exclude.length
      attributes.to_sh.except(*exclude)
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
        write_attribute(att, read_attribute(att).compact.uniq) if send("#{att}_changed?") || !id
      end
    end

    def array_attrs_unique?
      array_attributes.all? { |att, val| val == val.uniq }
    end

    def dup_without_relations(exclude: [], override: {}, keep: [])
      self.class.new attributes.to_sh.only( *( self.class.attribute_keys - exclude + keep).uniq ).merge(override.to_sh) 
    end

    def dup_without_relations!(exclude: [], override: {}, keep: [])
      the_dup = dup_without_relations(exclude: exclude, override: override, keep: keep)
      the_dup.save!
      the_dup
    end

    def g_token(attrs:, other: '')
      Digest::MD5.hexdigest( attrs.map{ |a| self.send(a) }.join("") + other.to_s )
    end

    private

    def cleaned(attrs, exceptions)
      attrs.reject{ |k, v| exceptions.include?(k) }
    end
  end
end