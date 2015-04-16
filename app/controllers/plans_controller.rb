class PlansController < ApplicationController
  
  before_action :load_plan, only: [:show, :print, :edit]
  before_action :authenticate_user!, only: [:new, :edit]

  def show
    if current_user_is_active && current_user.owns?(@plan)
      redirect_to "/?plan=#{@plan.id}"
    end
  end

  def print
  end

  def new
  end

  def edit
  end

  def index
    @plan = Plan.find_by( id: params[:plan] )
    if @plan.present? && ( !current_user || !current_user.owns?( @plan ) )
      redirect_to plan_path( @plan.id )
    elsif !current_user_is_active
      redirect_to beta_path
    end
  end

  private

  def load_plan
    @plan = Plan.includes(legs: [{ days: [{ items: [{mark: :place}] }] }] )
                .friendly.find( params[:id] )
  end

end