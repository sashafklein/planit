module PlaceMod
  class Address

    include RegexLibrary

    attr_reader :address, :regex_library
    def initialize(address)
      @address = address
    end

    def format
      return nil unless address
      expand_spaces! # Allows for non-competing global gsubs
      protect_cardinal_street_names!
      expand_directions!
      decode_cardinal_street_names!
      expand_street_descriptors!
      compact_spaces!
    end

    private

    def expand_spaces!
      @address.gsub!(/\s/) { "         " }
    end

    def compact_spaces!
      @address.gsub(/\s+/) { ' ' }
    end

    def expand_directions!
      regex = %r{
        \s
        (#{ cardinal_directions_list.join('|') })
        (\s|\z)
      }x
      @address.gsub!(regex) { " #{cardinal_directions_hash[$1]}#{$2}" }
    end

    def protect_cardinal_street_names!
      regex = %r{
        \s
        (#{ cardinal_directions_list.join('|') })
        \s+
        ((?:
          (?:#{ abbrev_streets_list.join('|') })
          (?:,|.|;|\s|\z))
          |
          (?:#{ full_streets_list.join('|') })
        )
      }x
      @address.gsub!(regex) { "*#{$1}*    #{$2}" }
    end

    def decode_cardinal_street_names!
      regex = %r{
        (\*
        (?:#{ cardinal_directions_list.join('|') })
        \*)
      }x
      @address.gsub!(regex) { $1.gsub("*", '') }
    end

    def expand_street_descriptors!
      regex = %r{
        \s
        (
          #{ abbrev_streets_list.join('|') }
        )
        (\.|,|\z|\s+
          (?:
            #{ (cardinal_directions_list + cardinal_directions_hash.values).flatten.join('|') }
          )
        )
      }x
      @address.gsub!(regex) { " #{ streets_list_hash[$1] }#{ $2.gsub(".", '') }" }
    end
  end
end