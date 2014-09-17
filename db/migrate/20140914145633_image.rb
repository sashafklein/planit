class Image < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url
      t.string :source
      t.string :source_url
      t.string :subtitle
      t.string :imageable_type
      t.references :imageable, polymorphic: true
      t.integer :uploader_id
      t.timestamps
    end

    add_index :images, :uploader_id
  end
end
