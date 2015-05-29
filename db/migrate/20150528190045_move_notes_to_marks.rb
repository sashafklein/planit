class MoveNotesToMarks < ActiveRecord::Migration
  def up
    Note.where(obj_type: 'Item').find_each do |note|
      note.obj = note.obj.mark
      note.save!
    end
  end

  def down
    Note.where(obj_type: 'Mark').find_each do |note|
      note.obj = Item.find_by(mark_id: note.obj_id)
      note.save!
    end
  end
end
