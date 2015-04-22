ActiveAdmin.register Share do

  index do 
    column :id
    column :sharer              do |s|  link_to( s.sharer.name, user_path(s.sharer) ) end
    column :sharee              do |s|  (s.sharee ? link_to( s.sharee.class.to_s, user_path(s.sharee) ) : nil) end
    column :object              do |s|  (s.object ? link_to( s.object.class.to_s, user_path(s.object) ) : nil) end
    column :created_at          do |s|  s.created_at.strftime("%-l:%M%P %b %d '%y") end
    column :viewed
    column :accepted
    actions
  end

end
