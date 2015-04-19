class MarkValidator < BaseValidator
  
  def validate(mark)
    super
    validate_presence!(:user, :user_id)
    validate_group_uniqueness!([:user_id, :place_id])
  end

end 