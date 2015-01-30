class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.text :details
      t.string :name
      t.references :object, polymorphic: true, index: true
      t.json :info

      t.timestamps
    end

    remove_column :places, :flags
  end
end
