class ParsedHstore

  def initialize(hash)
    new_hash = {}
    hash.each do |key, value|
      if value.is_a?(String) && is_json_hash?(value)
        new_hash[key] = ParsedHstore.new( JSON.parse(value.gsub("=>", ":")) ).value
      elsif value.is_a? Hash
        new_hash[key] = ParsedHstore.new(value).value
      elsif value.is_a? Array
        new_hash[key] = value.map{ |e| ParsedHstore.new(e).value }
      else
        new_hash[key] = value
      end
    end
    @value = new_hash
  end

  def value
    @value
  end

  private

  def is_json_hash?(string)
    string[0..1] == "{\"" && string[-2..-1] == "\"}"
  end
end