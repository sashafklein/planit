class AddUserIdAndPolymorphicAssociationToItems < ActiveRecord::Migration
  def change
    add_column :items, :user_id, :integer
    add_column :items, :groupable_type, :string
    add_column :items, :groupable_id, :integer

    add_index :items, :groupable_id
    add_index :items, :groupable_type
    add_index :items, :user_id
  end
end
