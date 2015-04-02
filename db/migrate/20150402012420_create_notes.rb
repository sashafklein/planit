class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :object, polymorphic: true, index: true
      t.references :source, polymorphic: true, index: true
      t.text :body

      t.timestamps null: false
    end

    remove_column :marks, :notes
    remove_column :legs, :notes
    remove_column :days, :notes
    remove_column :plans, :tips
  end
end
