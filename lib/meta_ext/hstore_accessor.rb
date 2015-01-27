module MetaExt
  module HstoreAccessor
      
    module ClassMethods

      def hstore_accessor(*symbols)
        symbols.each do |field|
          class_eval do 
            define_method(field) do
              SuperHash.new ParsedHstore.new(self[field.to_sym]).hash_value
            end

            define_method("add_to_#{field}!") do |arg|
              self[field.to_sym] = self[field.to_sym].merge(arg)
              send("#{field}_will_change!")
              save
              arg
            end

            define_method("add_to_#{field}") do |arg|
              self[field.to_sym] = self[field.to_sym].merge(arg)
              send("#{field}_will_change!")
              arg
            end

            define_method("remove_from_#{field}") do |arg|
              other = self[field].dup
              other.delete(arg.to_s); other.delete(arg.to_sym)
              self[field.to_sym] = other
              send("#{field}_will_change!")
              self[field.to_sym]
            end

            define_method("remove_from_#{field}!") do |arg|
              other = self[field].dup
              other.delete(arg.to_s); other.delete(arg.to_sym)
              self[field.to_sym] = other
              send("#{field}_will_change!")
              save
              self[field.to_sym]
            end

            define_method("set_#{field}") do |arg|
              self[field.to_sym] = arg
              send("#{field}_will_change!")
              self[field.to_sym]
            end

            define_method("set_#{field}!") do |arg|
              self[field.to_sym] = arg
              send("#{field}_will_change!")
              self[field.to_sym]
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end