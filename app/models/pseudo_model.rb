module PseudoModel
  def set_as_instance_variables(hash, default_hash={})
    hash.keys.each do |k|
      instance_variable_set("@#{k}", hash.delete(k))
      singleton_class.class_eval do 
        attr_accessor k
      end
    end

    default_hash.each do |k, v|
      unless respond_to?(k)
        create_method(k) { v }
      end
    end
  end

  def create_method(name, &block)
    singleton_class.send(:define_method, name, &block)
  end
end