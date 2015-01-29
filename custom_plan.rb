require 'zeus/rails'

class CustomPlan < Zeus::Rails

  def rspec(argv=ARGV)
    test(argv)
  end
  
end

Zeus.plan = CustomPlan.new
