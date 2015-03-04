module MetaExt
  module Base

    module ClassMethods

      def metaclass
        class << self; self; end
      end
      
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

      def boolean_accessor(*symbols)
        symbols.each do |symbol|

          metaclass.instance_eval do 
            define_method(symbol) do
              where(symbol => true)
            end

            define_method("not_#{symbol}") do
              where(symbol => false)
            end
          end

        end
      end

      def make_taggable
        acts_as_taggable

        class_eval do 
          define_method("tag!") do |arg|
            tag_list.add( arg )
            save!
          end

          define_method("untag!") do
            tag_list.remove( arg )
            save
          end
        end
      end

      def has_many_polymorphic(table:, name: :object, options: { dependent: :destroy })
        has_many table, options.merge({ as: name })

        metaclass.instance_eval do
          define_method( table ) do
            table.to_s.singularize.capitalize.constantize.where( 
              "#{name.to_s}_type".to_sym => self.name, 
              "#{name.to_s}_id".to_sym => pluck(:id)
            )
          end
        end

      Image.where( imageable_type: 'Place', imageable_id: 
        Place.where(id: 
          Mark.where(id:
            Item.where( plan_id: 
              Plan.where(id: ids)
            ).pluck(:mark_id)
          ).pluck(:place_id)
        ).pluck(:id)
      )
      
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
        write_attribute(att, read_attribute(att).compact.uniq) if send("#{att}_changed?") || !id
      end
    end

    def array_attrs_unique?
      array_attributes.all? { |att, val| val == val.uniq }
    end

    private

    def cleaned(attrs, exceptions)
      attrs.reject{ |k, v| exceptions.include?(k) }
    end
  end
end