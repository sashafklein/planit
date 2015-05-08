class AddColumnMetaCategoryToItems < ActiveRecord::Migration
  def change
    add_column :items, :meta_category, :string, limit: 25
    Item.find_each do |item|
      item.update_attributes( meta_category: item.mark.place.meta_category ) if item.mark.try( :place )
    end
  end
end
