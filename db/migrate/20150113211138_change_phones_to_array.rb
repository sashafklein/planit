class ChangePhonesToArray < ActiveRecord::Migration
  def up
    new_phones = {}
    Place.find_each do |p|
      new_phones[p.id] = p.phones.values.map{ |v| v.gsub(%r!\D!, '') }
    end

    remove_column :places, :phones
    add_column :places, :phones, :string, array: true, default: []
    Place.reset_column_information

    new_phones.each do |k, v|
      p = Place.find(k)
      p.phones_will_change!
      p.update_attributes!(phones: v)
    end
  end

  def down
    new_phones = {}
    Place.find_each do |p|
      new_phones[p.id] = p.phones.values.map{ |v| v.gsub(%r!\D!, '') }
    end

    remove_column :places, :phones
    add_column :places, :phones, :hstore, default: {}
    Place.reset_column_information
    
    new_phones.each do |k, v|
      p = Place.find(k)
      p.phones_will_change!
      p.update_attributes!({ phones: { default: v.first } })
    end
  end
end
