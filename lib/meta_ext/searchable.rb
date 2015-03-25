module MetaExt
  module Searchable
    module ClassMethods
      def elastic_searchable(columns_and_weights: [], fuzziness: 'AUTO')
        include Elasticsearch::Model

        import

        metaclass.instance_eval do 

          define_method(:search) do |query|
            __elasticsearch__.search({
                query: {
                  multi_match: {
                    query: query,
                    fields: columns_and_weights,
                    fuzziness: fuzziness,
                  }
                } })
          end

          define_method(:filtered_search) do |query_and_filter|

            query = query_and_filter[:query]
            filter = query_and_filter[:filter]

            if filter[:query] && filter[:query].present?

              __elasticsearch__.search({
                  query: {
                    bool: {
                      should: [
                        { multi_match: query },
                        { multi_match: filter }
                      ],
                      minimum_should_match: 2
                    }                    
                  } })

            else

              __elasticsearch__.search({
                  query: { multi_match: query }
                })

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