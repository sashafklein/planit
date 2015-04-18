module MetaExt
  module Polymorphism
    module ClassMethods
      def has_many_polymorphic(table:, name: :object, options: { dependent: :destroy })
        has_many table, options.merge({ as: name })
        
        metaclass.instance_eval do
          define_method( table ) do
            table.to_s.singularize.camelize.constantize.where( 
              "#{name.to_s}_type".to_sym => self.name, 
              "#{name.to_s}_id".to_sym => pluck(:id)
            )
          end
        end
      end

      def is_polymorphic(name: :object, should_validate: true)
        belongs_to name, polymorphic: true

        validates( name, "#{name}_type".to_sym, "#{name}_id".to_sym, presence: true ) if should_validate

        metaclass.instance_eval do 
          define_method(:repoint!) do |new_object|
            all.each{ |poly| poly.repoint!(new_object) }
          end
        end

        class_eval do 
          define_method(:repoint!) do |new_object|
            send("#{name}=", new_object); save!
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def copy_polymorphic!(to:, relation:, other_attrs: {})
      self.class.transaction do 
        send(relation).each do |obj|
          obj.dup_without_relations!( override: {object: to}.merge(other_attrs) )
        end
      end
    end
  end
end