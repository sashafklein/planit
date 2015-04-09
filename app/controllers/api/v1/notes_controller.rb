class Api::V1::NotesController < ApiController
  def create
    return permission_denied_error unless current_user
    if params[:object_type] == 'Place'
      params[:object_type] = 'Mark'
      params[:object_id] = Mark.where(place_id: params[:object_id])
      current_user.notes.create! params.require(:note).permit(:object_id, :object_type, :body)
      success
    else
      current_user.notes.create! params.require(:note).permit(:object_id, :object_type, :body)
      success
    end
  end
end