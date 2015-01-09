class ParsedHstore

  attr_reader :value
  def initialize(input)
    array = input.is_a?(Array) ? input : [input]
    @value = array.map do |hash|
      if hash.is_a?(Hash)
        hash.reduce_to_hash do |key, value|
          if is_json_string?(value)
            wrap( clean_json(value) ).value
          elsif is_hash_string?(value)
            wrap( clean_hash(value) ).value
          elsif value.is_a? Hash
            wrap( value ).value
          elsif value.is_a? Array
            value.map{ |e| self.class.new(e).value }
          else
            value
          end
        end
      else
        hash
      end
    end
  end

  def hash_value
    value.first
  end

  private

  def wrap(input)
    self.class.new input
  end

  def is_json_string?(input)
    input.is_a?(String) && (
      (input[0..1] == "{\"" && input[-2..-1] == "\"}") || 
      (input[0..2] == "[{\"" && input[-3..-1] == "\"}]") || 
      (input[0..2] == "[[\"" && input[-3..-1] == "\"]]")
    )
  end

  def is_hash_string?(input)
    input.is_a?(String) && (
      (input[0..1] == "{:" && input[-2..-1] == "\"}") || 
      (input[0..2] == "[{:" && input[-3..-1] == "\"}]")
    )
  end

  def clean_json(json_string)
    JSON.parse( json_string.gsub("=>", ":").gsub('nil', 'null') )
  end

  def clean_hash(hash_string)
    JSON.parse( hash_string.gsub("{:", "{\"").gsub(", :", ", \"").gsub("=>", "\": ").gsub('nil', 'null') )
  end

  def is_array?(value)
    "[[\"1200\", \"0000\"]]"
  end
end