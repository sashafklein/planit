class Env
  def self.method_missing(m)
    ENV[m.to_s.upcase]
  end
end