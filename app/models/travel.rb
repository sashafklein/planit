class Travel < BaseModel
  belongs_to :from, class_name: 'Item'
  belongs_to :to, class_name: 'Item'
  has_one :next_step, class_name: 'Travel'

  def previous_step
    Travel.find_by_next_step_id(id)
  end

  def terminus
    next_step_id ? next_step.terminus : to
  end

  def origin
    previous_step ? previous_step.origin : from
  end
end
