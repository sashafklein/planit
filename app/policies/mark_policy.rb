class MarkPolicy < ApplicationPolicy
  attr_reader :user, :mark

  def initialize(user, mark)
    @user = user
    @mark = mark
  end

  def index?
    false
  end

  def show?
    mark.published? ? member? : admin? || owns?
  end

  def create?
    member?
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
    update?
  end

  private

  def record
    mark
  end

end

