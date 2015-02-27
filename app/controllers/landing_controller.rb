class LandingController < ApplicationController
  
  def show
    if !current_user
      redirect_to index_path
    elsif current_user.pending?
      redirect_to waitlist_path
    else
      redirect_to user_path(current_user)
    end
  end

end