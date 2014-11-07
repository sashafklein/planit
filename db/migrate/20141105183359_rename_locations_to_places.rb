class RenameLocationsToPlaces < ActiveRecord::Migration
  def change
    rename_table :locations, :places
    
    # Change Name to a "Names" array column, with both name and local name
    name_hash = {}
    Place.find_each do |p|
        name_hash[p.id] = [p.name, p.local_name].reject{ |n| n.blank? }
    end

    remove_column :places, :name
    remove_column :places, :local_name
    add_column :places, :names, :string, array: true
    
    name_hash.each do |k, v|
      Place.find(k).update_attributes!(names: v)
    end

    # Change Phone to an HStore
    place_hash = {}
    
    Place.where.not(phone: '').find_each do |place|
      place_hash[place.id] = place.phone
    end
    
    enable_extension :hstore
    remove_column :places, :phone
    add_column :places, :phones, :hstore

    place_hash.each do |k, v|
      place = Place.find(k)
      place.phones = {default: v}
      place.save!
    end

    # Rename City and State to Locality and Region
    rename_column :places, :city, :locality
    rename_column :places, :state, :region

    # Rename Genre/Subgenre to Category/Subcategory
    rename_column :places, :genre, :category
    rename_column :places, :subgenre, :subcategory

    # Add Email, ContactName, Hours (HStore), 
    # PriceTier, PriceNote, Description, Extra (HStore)
    add_column :places, :email, :string
    add_column :places, :contact_name, :string
    add_column :places, :hours, :hstore
    add_column :places, :price_tier, :integer
    add_column :places, :price_note, :string
    add_column :places, :description, :text
    add_column :places, :extra, :hstore
  end
end
