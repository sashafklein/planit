class CreateMailListEmails < ActiveRecord::Migration
  def change

    create_table :accepted_emails do |t|
      t.string :email, unique: true

      t.timestamps null: false
    end

    create_table :mail_list_emails do |t|
      t.string :email, unique: true
      t.string :first_name
      t.string :last_name

      t.timestamps null: false
    end

    User.where.not(role: 0).find_each do |user|
      AcceptedEmail.create!(email: user.email)
    end

    User.all.find_each do |user|
      MailListEmail.create!(email: user.email, first_name: user.first_name, last_name: user.last_name)
    end

    MailListEmail.all.find_each do |email|
      if user = email.user 
        user.destroy if user.pending?
      end
    end

  end
end
