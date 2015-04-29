class DelayPlanCopyJob < ActiveJob::Base
  def perform(plan_id:, user_id:, copy_manifest: false)
    plan = Plan.find(plan_id)
    user = User.find(user_id)
    
    new_plan = plan.copy!(new_user: user, copy_manifest: copy_manifest)

    Pusher.trigger("copy-plan-#{plan_id}", 'copied', { id: new_plan.id })
  end
end