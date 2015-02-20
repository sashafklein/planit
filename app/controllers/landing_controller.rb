class LandingController < ApplicationController
  
  def show
    if !current_user
      redirect_to index_path
      # redirect_to new_user_session_path
    elsif current_user.pending?
      redirect_to waitlist_path
      # raise
    else
      redirect_to user_path(current_user)
    end
  end

end