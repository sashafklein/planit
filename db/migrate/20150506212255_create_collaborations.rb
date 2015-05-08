class CreateCollaborations < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
      t.integer :collaborator_id, null: false
      t.integer :plan_id, null: false
      t.integer :permission, default: 0

      t.timestamps null: false
    end
    add_index :collaborations, :collaborator_id
    add_index :collaborations, :plan_id
  end
end
