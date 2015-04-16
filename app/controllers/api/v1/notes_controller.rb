class Api::V1::NotesController < ApiController
  def create
    return permission_denied_error unless current_user
    if params[:object_type] == 'Place' # converts place to marks
      params[:object_type] = 'Mark'
      params[:object_id] = Mark.where(place_id: params[:object_id])
    end
    edit_or_create
  end

  def find_by_object
    note = Note.where( object_type: params[:object_type], object_id: params[:object_id] ).first
    if note
      render json: { body: note.body } 
    else
      render json: { body: nil }
    end
  end

  private

  def edit_or_create
    note = current_user.notes.where( note_params.slice(:object_id, :object_type) ).first_or_initialize
    note.body = note_params[:body]
    note.save!
    render json: { body: note.body }
  end

  def note_params
    params.require(:note).permit(:object_id, :object_type, :body)
  end
end