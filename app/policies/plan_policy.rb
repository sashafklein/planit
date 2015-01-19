class PlanPolicy < ApplicationPolicy
  attr_reader :user, :plan

  def initialize(user, plan)
    @user = user
    @plan = plan
  end

  def index?
    false
  end

  def show?
    if @plan.private == true
      @user.admin? || @user.plans.include?(@plan)
    else
      true
    end
    # scope.where(:id => record.id).exists?
  end

  def create?
    @user?
  end

  def new?
    create?
  end

  def update?
    @user.admin? || @user.plans.include?(@plan)
  end

  def edit?
    update?
  end

  def destroy?
    @user.admin? || @user.plans.include?(@plan)
  end

end

