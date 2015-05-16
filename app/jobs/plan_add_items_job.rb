class PlanAddItemsJob < ActiveJob::Base
  
  def perform(plan_id:, item_ids:)
    plan = Plan.find(plan_id)
    plan.add_items!( Item.where(id: item_ids) )
  
    Pusher.trigger("add-items-to-plan-#{ plan.id }", 'added', {})
  end
end