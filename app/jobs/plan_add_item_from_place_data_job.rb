class PlanAddItemFromPlaceDataJob < ActiveJob::Base
  queue_as :completer

  def perform(user_id:, plan_id:, data:)
    user = User.find(user_id)
    plan = user.plans.find_by(id: plan_id)
    
    return Rollbar.error("Failed to find that plan for the given user", { user_id: user_id, plan_id: plan_id, data: data }) unless plan

    item = plan.add_item_from_place_data!(user, data)

    return Rollbar.error("Insufficient Place data.", { plan_id: plan_id, user_id: user_id, data: data }) unless item

    Pusher.trigger("add-item-from-place-data-to-plan-#{plan_id}", 'added', { item_id: item.id })
  end
end