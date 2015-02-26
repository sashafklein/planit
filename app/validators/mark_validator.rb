class MarkValidator < BaseValidator
  
  def validate(mark)
    super
    validate_presence!(:user, :user_id)
  end

end 