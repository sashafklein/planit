ActiveAdmin.register Plan do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
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
