class UsersController < ApplicationController
  
  before_action :load_user, only: [:bucket, :show]

  def bucket
    @marks = @user.marks.includes(:places)
  end

  def show
    @marks = @user.marks.includes(:places)
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

end