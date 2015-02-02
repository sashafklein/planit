class HstoreToJson < ActiveRecord::Migration
  def up
    change_hash_column_type Place, :extra, :json
    change_hash_column_type Place, :hours, :json
    change_hash_column_type Item, :extra, :json
  end

  def down
    change_hash_column_type Place, :extra, :hstore
    change_hash_column_type Place, :hours, :hstore
    change_hash_column_type Item, :extra, :hstore
  end

  def change_hash_column_type(class_name, column_name, new_type)
    array = []

    class_name.order('id ASC').each do |object|
      array << (new_type == :json ? ParsedHstore.new(object[:column_name]).hash_value : object[:column_name])
    end

    table_name = class_name.to_s.downcase.pluralize
    remove_column table_name, column_name
    add_column table_name, column_name, new_type, default: {}
    class_name.reset_column_information

    class_name.order('id ASC').each_with_index do |object, index|
      object[column_name] = array[index]
      object.send("#{column_name}_will_change!")
      object.save!
    end
  end
end
