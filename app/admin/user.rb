ActiveAdmin.register User do

  permit_params :email, :role

  index do |t|
    column :id
    column :name              do |u|  link_to u.name, user_path(u)  end
    column :email
    column :sign_in_count
    column :last_sign_in_at   do |u|  u.last_sign_in_at.strftime("%-l:%M%P %b %d '%y")  end
    column :created_at        do |u|  u.created_at.strftime("%-l:%M%P %b %d '%y")  end
    column :role
    column :plans_count       do |u|  u.plans.count  end
    column :items_count       do |u|  u.items.count  end
    column :shares_count      do |u|  u.shares.count  end
  end

end
