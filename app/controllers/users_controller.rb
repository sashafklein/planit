class UsersController < ApplicationController
  
  before_action :load_user, only: [:places, :guides, :inbox, :show]
  before_action :authorize_user, only: [:places, :guides, :inbox, :show]

  def beta
    user = User.new( params.require(:user).permit(:first_name, :last_name, :email) ).save_as_beta
    if user.persisted?
      flash[:success] = "Great! You'll receive a confirmation shortly"
    else
      user.valid?
      flash[:error] = "Woops! #{user.errors.full_messages.first}"
    end
    redirect_to root_path
  end

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