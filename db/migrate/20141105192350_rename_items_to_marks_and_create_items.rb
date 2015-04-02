class RenameItemsToMarksAndCreateItems < ActiveRecord::Migration
  def up
    rename_table :items, :marks

    create_table :items do |t|
      t.integer :mark_id
      t.integer :plan_id
      t.integer :day_id
      t.integer :order
      t.integer :day_of_week, default: 0
      t.string  :start_time
      t.float   :duration
      t.string
    end

    Mark.unscoped.find_each do |mark|
      if mark.day_id 
        Item.create({
          mark_id: mark.id,
          plan_id: mark.plan.try(:id),
          day_id: mark.day_id,
          order: mark.order
        })
      end
    end

    remove_column :marks, :day_id
    remove_column :marks, :order
    
    if Mark.unscoped.column_names.include?("location_id")
      rename_column :marks, :location_id, :place_id
    end

    add_index :items, :plan_id
    add_index :items, :day_id
    add_index :items, :mark_id

    # add_index :marks, :place_id
  end

  def down
    add_column :marks, :day_id, :integer
    add_column :marks, :order, :integer

    Item.find_each do |item|
      mark = Mark.unscoped.find(item.mark_id)
      mark.day_id = item.day_id
      mark.order = item.order
      mark.save!
    end

    drop_table :items
    rename_table :marks, :items
  end
end
