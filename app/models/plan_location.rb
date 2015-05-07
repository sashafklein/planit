class PlanLocation < ActiveRecord::Base
  belongs_to :plan
  belongs_to :location
end
