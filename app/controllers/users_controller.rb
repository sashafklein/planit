class UsersController < ApplicationController
  
  before_action :load_user, only: [:bucket]

  def bucket
    # return error(404, "User not found") unless @user

    @marks = @user.marks.includes(:places)
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  rescue
    @user = nil
  end

end