class MarkValidator < BaseValidator
  
  def validate(mark)
    super
    validate_presence!(:user, :user_id)
    validate_user_place_uniqueness!
  end

  def validate_user_place_uniqueness!
    return unless mark.place_id && mark.user_id
    other = Mark.find_by(place_id: mark.place_id, user_id: mark.user_id)
    if other && other.id != mark.id
      mark.errors[:base] << "A Mark with that user_id and place_id already exists. mark_id: #{other.id}, user_id: #{other.user_id}, place_id: #{other.place_id}"
    end
  end

end 