class PlansController < ApplicationController
  
  before_action :load_plan, only: [:show, :print, :mobile]

  def show
  end

  def new
  end

  def new2
  end

  def jmt
    redirect_to plan_path("john-muir-trail-north-south")
  end

  def welcome
  end

  def print
  end

  def mobile
  end

  private

  def load_plan
    @plan = Plan.includes(:moneyshots, legs: [{ days: [{ items: [:location, :arrival, :departure] }] }] )
                .friendly.find(params[:id])
  end

end