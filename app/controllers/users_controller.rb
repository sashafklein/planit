class UsersController < ApplicationController
  
  before_action :load_user, only: [:places, :guides, :inbox, :show]
  before_action :authorize_user, only: [:places, :guides, :inbox, :show]

  def places
    @marks = @user.marks.includes(:place)
  end

  def show
    marks = @user.marks.includes(:place)
    @marks = (admin? || same_user?) ? marks : marks.where(published: true)
  end

  def inbox
  end

  private

  def load_user
    @user = User.friendly.find(params[:id])
  end

  def authorize_user
    authorize @user
  end

end