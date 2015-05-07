ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end
end

ActiveAdmin.register AcceptedEmail do

  permit_params :email

end

ActiveAdmin.register Item do

  index do 
    column :id
    column :plan              do |i|  link_to i.plan.name, plan_path(i.plan)  end
    column :created_at        do |i|  i.created_at.strftime("%-l:%M%P %b %d '%y")  end
    actions
  end

end

ActiveAdmin.register MailListEmail do

  permit_params :email, :first_name, :last_name

end

ActiveAdmin.register Plan do

  permit_params :name
  index do
    column :id
    column :name              do |p|  link_to p.name, plan_path(p)  end
    column :user              do |p|  link_to p.user.name, user_path(p.user) end
    column :created_at        do |p|  p.created_at.strftime("%-l:%M%P %b %d '%y") end
    column :items             do |p|  p.items.count end
    column :permission
    actions
  end

end

ActiveAdmin.register Share do

  index do 
    column :id
    column :sharer              do |s|  link_to( s.sharer.name, user_path(s.sharer) ) end
    column :sharee              do |s|  (s.sharee ? link_to( s.sharee.class.to_s, user_path(s.sharee) ) : nil) end
    column :obj              do |s|  (s.obj ? link_to( s.obj.class.to_s, user_path(s.obj) ) : nil) end
    column :created_at          do |s|  s.created_at.strftime("%-l:%M%P %b %d '%y") end
    column :viewed
    column :accepted
    actions
  end

end

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
    actions
  end

end

