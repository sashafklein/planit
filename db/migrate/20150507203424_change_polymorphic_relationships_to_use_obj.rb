class ChangePolymorphicRelationshipsToUseObj < ActiveRecord::Migration
  def change
    rename_column :notes, :object_id, :obj_id
    rename_column :notes, :object_type, :obj_type
    rename_column :flags, :object_id, :obj_id
    rename_column :flags, :object_type, :obj_type
    rename_column :shares, :object_id, :obj_id
    rename_column :shares, :object_type, :obj_type
    rename_column :sources, :object_id, :obj_id
    rename_column :sources, :object_type, :obj_type
  end
end
