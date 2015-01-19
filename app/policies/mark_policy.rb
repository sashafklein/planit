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
    if @mark.private == true
      @user.admin? || @user.marks.include?(@mark)
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
    @user.admin? || @user.marks.include?(@mark)
  end

  def edit?
    update?
  end

  def destroy?
    @user.admin? || @user.marks.include?(@mark)
  end

end

