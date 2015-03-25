class UserPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def show?
    member?
  end

  def places?
    member?
  end

  def guides?
    member?
  end

  def inbox?
    owns?
  end

  def recent?
    owns?
  end

  def nearby?
    owns?
  end

  # def update?
  #   admin?
  # end

  # def edit?
  #   update?
  # end

  # def destroy?
  #   admin?
  # end

end

