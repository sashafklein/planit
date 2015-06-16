class CreateClusters < ActiveRecord::Migration
  def up
    create_table :clusters do |t|
      t.string :name, null: false
      t.integer :country_id, null: false
      t.float :lat, null: false
      t.float :lon, null: false
      t.integer :rank, default: 0
      t.string :image_url
      t.integer :geoname_id

      t.timestamps null: false
    end

    add_index :clusters, :country_id
  end

  def down
    drop_table :clusters
  end
end
