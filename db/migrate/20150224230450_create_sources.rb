class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.references :object, polymorphic: true, index: true
      t.string :name
      t.string :full_url
      t.string :trimmed_url
      t.string :base_url
      t.text :description

      t.timestamps null: false
    end
  end
end
