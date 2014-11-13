class Hash
  
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end

  def recursive_delete_if(&block)
    hash = dup
    hash.each do |k, v|
      if yield(k, v)
        hash.delete(k)
      elsif v.is_a? Hash
        hash[k] = v.recursive_delete_if(&block)
      end
      hash
    end
  end

end