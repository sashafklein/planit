class UsersController < ApplicationController
  
  before_action :load_user, only: [:places, :guides, :inbox, :show]
  before_action :authorize_user, only: [:places, :guides, :inbox, :show]
  before_action :authenticate_member!, only: [:invite, :places, :guides, :inbox, :show, :share]

  def beta
    if existing_user = User.where( email: user_params[:email] ).first
      user_exists(existing_user)
    else
      user = User.new( user_params ).save_as(:pending)
      if user.persisted?
        flash[:success] = "Great! You'll receive a confirmation shortly"
      else
        invalidation_error(user)
      end
    end
    redirect_to root_path
  end

  def invite
    if existing_user = User.where( email: user_params[:email], role: User.roles[:member.to_s] ).first
      user_exists(existing_user)
    else
      user = User.where( email: user_params[:email] ).first_or_initialize( user_params.except( :email ) )
      user.save_as(:member)
      if user.persisted?
        flash[:success] = "Great! We've sent an invitation to #{user.first_name}"
      else
        invalidation_error(user)
      end
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

  def invalidation_error(user)
    unless user.valid?
      flash[:error] = "Woops! #{user.errors.full_messages.first}"
    else
      flash[:error] = "Woops! Something went wrong"
    end
  end

  def user_exists(user)
    flash[:error] = "#{user.first_name} is already a Planit member!" if user.member?
    flash[:error] = "#{user.first_name} is already on the Beta list!" if user.pending?    
  end

  def user_params
   params.require(:user).permit(:first_name, :last_name, :email) 
  end

end