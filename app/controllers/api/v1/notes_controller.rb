class Api::V1::NotesController < ApiController
  def create
    return permission_denied_error unless current_user
    if note_params[:obj_type] == 'Place' # converts place to marks
      note_params[:obj_type] = 'Mark'
      note_params[:obj_id] = Mark.find_by(user_id: current_user, place_id: note_params[:obj_id]).id
    end
    edit_or_create
  end

  def find_all_notes_in_plan
    return error( status: 500, message: 'Insufficient Information' ) unless params[:plan_id]

    item_ids = Item.where( plan_id: params[:plan_id] ).pluck(:id)
    render json: Note.where( obj_type: 'Item', obj_id: item_ids ), each_serializer: NoteSerializer
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
    if note_body.length > 0
      # object = note_params[:obj_type].to_s.singularize.camelize.constantize.find( note_params[:obj_id] )
      # return permission_denied_error unless object && current_user.owns?( object )
      note = current_user.notes.where( note_params.slice(:obj_id, :obj_type) ).first_or_initialize
      note.body = note_body
      note.save!
      render json: { body: note.body }
    else
      note = current_user.notes.where( note_params.slice(:obj_id, :obj_type) ).first
      if note then note.destroy() end
      return success
    end
  end

  def note_params
    params.require(:note).permit(:obj_id, :obj_type, :body)
  end
end