class PlansController < ApplicationController
  
  before_action :load_plan, only: [:show, :print, :edit]
  before_action :authenticate_user!, only: [:new, :edit]

  def show
  end

  def print
  end

  def new
  end

  def edit
  end

  def index
    if current_user
      redirect_to user_path(current_user)+"/guides"
    else
      redirect_to new_user_session_path
    end
  end

  private

  def load_plan
    @plan = Plan.includes(legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .friendly.find(params[:id])
  end

end