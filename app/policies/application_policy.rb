class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    admin? || owns?
  end

  def create?
    member?
    # user.present?
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    user ? user.admin? : false
  end 

  def member?
    user ? user.member? || user.admin? : false
  end 

  def owns?
    user.owns?(record) || user.is?(record)
  end
end

