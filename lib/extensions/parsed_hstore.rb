class ParsedHstore

  attr_reader :value
  def initialize(hash)
    @value = hash.reduce_to_hash do |key, value|
      
      if is_json_string?(value)
        wrap( clean(value) ).value
      elsif value.is_a? Hash
        wrap( value ).value
      elsif value.is_a? Array
        value.map{ |e| self.class.new(e).value }
      else
        value
      end
      
    end
  end

  private

  def wrap(input)
    self.class.new input
  end

  def is_json_string?(input)
    input.is_a?(String) && input[0..1] == "{\"" && input[-2..-1] == "\"}"
  end

  def clean(json_string)
    JSON.parse( json_string.gsub("=>", ":") )
  end
end