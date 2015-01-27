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
    plan.published? ? user : admin? || owns?
  end

  def create?
    user?
  end

  def new?
    create?
  end

  def update?
    admin? || owns?
  end

  def edit?
    update?
  end

  def destroy?
    admin? || owns?
  end

  private

  def record
    plan
  end
end

