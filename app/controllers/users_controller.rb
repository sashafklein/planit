class UsersController < ApplicationController
  
  before_action :load_user, only: [:bucket, :dashboard]

  def bucket
    @marks = @user.marks.includes(:places)
  end

  def dashboard
    @marks = @user.marks.includes(:places)
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

end