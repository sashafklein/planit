class PlansController < ApplicationController
  
  before_action :load_yaml_data, only: [:show, :print]

  def show
  end

  def new
  end

  def jmt
    redirect_to plan_path('john-muir-trail')
  end

  def welcome
  end

  def print
  end

  private

  def load_yaml_data
    file_path = File.join(Rails.root, 'app', 'models', 'plans', 'yaml', "#{params[:id]}.yml")

    if !File.exists? file_path
      flash[:error] = "No plan exists by that name."
      redirect_to root_path
    else
      @plan = Plan.new YAML.load_file( file_path )
      @slugged_title = params[:id]
    end
  end

end