class Api::V1::NotesController < ApiController
  def create
    return permission_denied_error unless current_user
    current_user.notes.create! params.require(:note).permit(:object_id, :object_type, :body)
    success
  end
end