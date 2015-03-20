module MetaExt
  module Searchable
    module ClassMethods
      def elastic_searchable(columns_and_weights: [], fuzziness: 'AUTO')
        include Elasticsearch::Model

        import

        metaclass.instance_eval do 

          define_method(:search) do |query|
            __elasticsearch__.search(
              {
                query: {
                  multi_match: {
                    query: query,
                    fields: columns_and_weights,
                    fuzziness: fuzziness
                  }
                }
              }
            )
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end