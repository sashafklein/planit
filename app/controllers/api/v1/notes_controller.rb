class Api::V1::NotesController < ApiController
  def create
    return permission_denied_error unless current_user
    
    @obj_id = note_params[:obj_id] unless note_params[:obj_type] == 'Place'
    @obj_id ||= Mark.find_by(user_id: current_user, place_id: note_params[:obj_id]).id
    @obj_type = if note_params[:obj_type] == 'Place' then 'Mark' else note_params[:obj_type] end

    edit_or_create
  end

  def find_all_notes_in_plan
    return error( status: 500, message: 'Insufficient Information' ) unless params[:plan_id]

    mark_ids = Item.where( plan_id: params[:plan_id] ).pluck(:mark_id)
    render json: Note.where( obj_type: 'Mark', obj_id: mark_ids ), each_serializer: NoteSerializer
  end

  def find_by_object
    note = Note.where( obj_type: params[:obj_type], obj_id: params[:obj_id] ).first
    if note
      render json: { body: note.body } 
    else
      render json: { body: nil }
    end
  end

  private

  def edit_or_create
    return permission_denied_error unless current_user
    
    note_body = note_params[:body]
    object = @obj_type.to_s.singularize.camelize.constantize

    note = current_user.notes.where( obj: object.find( @obj_id ) ).first_or_initialize

    if note_body.length > 0
      note.update_attributes!(body: note_body)
      render json: { body: note.body }
    else
      if note.persisted? then note.destroy() end
      return success
    end
  end

  def note_params
    params.require(:note).permit(:obj_id, :obj_type, :body)
  end
end