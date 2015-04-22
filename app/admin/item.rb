ActiveAdmin.register Item do

  index do 
    column :id
    column :plan              do |i|  link_to i.plan.name, plan_path(i.plan)  end
    column :created_at        do |i|  i.created_at.strftime("%-l:%M%P %b %d '%y")  end
  end

end
