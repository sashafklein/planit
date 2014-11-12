class ChangeCategoryToCategories < ActiveRecord::Migration
  def up
    add_column :places, :categories, :string, array: true, default: []
    
    Place.find_each{ |p| p.update_attribute( :categories, [p.category, p.subcategory].compact )}
    
    remove_column :places, :category
    remove_column :places, :subcategory
  end

  def down
    add_column :places, :category, :string
    add_column :places, :subcategory, :string

    Place.find_each{ |p| p.update_attribute( :category, p.categories.first )}
    Place.find_each{ |p| p.update_attribute( :subcategory, p.categories[1] )}

    remove_column :places, :categories
  end
end
