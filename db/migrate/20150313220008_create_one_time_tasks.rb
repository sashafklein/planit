class CreateOneTimeTasks < ActiveRecord::Migration
  def change
    create_table :one_time_tasks do |t|
      t.string :action
      t.references :target, polymorphic: true, index: true
      t.references :agent, polymorphic: true, index: true
      t.string :detail
      t.json :extras

      t.timestamps null: false
    end
  end
end
