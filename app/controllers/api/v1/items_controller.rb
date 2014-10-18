class Api::V1::ItemsController < ApiController
  
  before_filter :find_user

  def create
    plan = @user.bucket_plan
  end

  private

  def find_user
    @user = User.friendly.find(params[:user_id])
    error(404, "User not found") unless @user
  end
end