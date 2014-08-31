module PseudoModel
  def set_as_instance_variables(hash, always_hash={})
    hash.keys.each do |k|
      instance_variable_set("@#{k}", hash.delete(k))
      singleton_class.class_eval do 
        attr_accessor k
      end
    end

    always_hash.each do |k, value|
      unless respond_to?(k)
        #
      end
    end
  end
end