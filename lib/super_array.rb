class SuperArray < Array
  def initialize(array=[])
    array.each_with_index do |v, i|
      if v.is_a?(Hash)
        self[i] = v.to_sh
      elsif v.is_a?(Array)
        self[i] = self.class.new(v)
      else
        self[i] = v
      end
    end

    self
  end
end