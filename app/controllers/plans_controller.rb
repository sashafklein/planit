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
    redirect_to beta_path if !current_user_is_active
  end

  private

  def load_plan
    @plan = Plan.includes(legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .friendly.find(params[:id])
  end

end