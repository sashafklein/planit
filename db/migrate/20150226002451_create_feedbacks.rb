class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :nps_feedbacks do |t|
      t.integer :rating
      t.integer :user_id

      t.timestamps null: false
    end

    create_table :page_feedbacks do |t|
      t.text :details
      t.string :url
      t.integer :nps_feedback_id
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :nps_feedbacks, :user_id
    add_index :page_feedbacks, :user_id
    add_index :page_feedbacks, :nps_feedback_id

  end
end
