class UsersController < ApplicationController
  
  before_action :load_user, only: [:show, :places, :inbox, :recent, :nearby, :search]
  before_action :authorize_user, only: [:show, :places, :inbox, :recent, :nearby, :search]
  before_action :authenticate_member!, only: [:invite, :places, :inbox, :show, :share, :recent, :nearby, :search]

  def waitlist
    if existing_user = User.where( email: user_params[:email] ).first
      redirect_and_flash new_user_session_path(email: user_params[:email]), error: "#{existing_user.first_name} is already a Planit member!"
    elsif accepted_email = AcceptedEmail.find_by(email: user_params[:email])
      redirect_and_flash new_user_registration_path(user_params), success: "You're on the accepted emails list! Create an account to sign in"
    elsif email = MailListEmail.waitlist!(user_params)
      redirect_and_flash root_path, success: "Great! We'll be in touch shortly"
    else
      Rollbar.error("Waitlisting failed", user_params)
      redirect_and_flash root_path, error: "Woops! Something went wrong. Please let us know"
    end
  end

  def invite
    unless user_params[:email].present? && MailListEmail.valid?(user_params[:email])
      return redirect_and_flash invite_path(user_params), error: "Please enter a valid email address"
    end

    user = User.where( email: user_params[:email] ).first_or_initialize( user_params.except( :email ) )

    if user.persisted?
      redirect_and_flash invite_path, error: "#{user.first_name} is already a Planit member!"
    else
      if user.invite!(current_user)
        redirect_and_flash invite_path, success: "Great! We've sent an invitation to #{user.first_name}"
      else
        redirect_and_flash invite_path, error: "Woops! Something went wrong. Please let us know"
      end
    end
  end

  def places
    @marks = @user.marks.includes(:place)
  end

  def show
    if @user == current_user
      redirect_to root_path
    end
  end

  def inbox
    if @user != current_user
      flash[:error] = "Not your inbox!"
      redirect_to user_path
    elsif @user.message_count == 0
      flash[:error] = "No Messages!"
      redirect_to user_path
    end
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

  def user_params
   params.require(:user).permit(:first_name, :last_name, :email) 
  end

end