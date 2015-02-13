module MetaExt
  module ArrayAccessor
      
    module ClassMethods

      def array_accessor(*symbols)
        symbols.each do |singular|

          plural = singular.to_s.split("_").join(" ").pluralize.split(" ").join("_")

          class_eval do 
            define_method("add_#{singular}") do |arg|
              send( "#{plural}=", (send(plural) + Array(arg)).uniq )
            end

            define_method(singular) do
              send(plural).compact.first
            end
          end

          metaclass.instance_eval do 
            define_method("without_#{singular}") do |arg=nil|
              if arg.blank?
                where("? = '{}'", plural)
              else
                where.not("? = ANY (#{plural})", arg.is_a?(Array) ? arg.first : arg)
              end
            end

            define_method("with_#{singular}") do |arg=nil|
              if arg.blank?
                where.not("? = '{}'", plural)
              else
                where("? = ANY (#{plural})", arg.is_a?(Array) ? arg.first : arg)
              end
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