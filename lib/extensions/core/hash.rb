class Hash
  
  def recursive_symbolize_keys
    hash = dup
    hash = hash.symbolize_keys
    
    hash.each do |k, v|
      if v.is_a? Hash
        hash[k] = v.recursive_symbolize_keys
      elsif v.is_a? Array
        hash[k] = v.map do |value|
          if value.is_a? Hash
            value.recursive_symbolize_keys 
          else
            value
          end
        end
      end
    end

    hash
  end

  def recursive_symbolize_keys!
    replace( recursive_symbolize_keys )
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

  def deep_val(indices, error=nil)
    hash = dup
    indices.map do |i|
      return error if hash.nil?
      hash = hash.send('[]', i)
    end
    hash
  end
end