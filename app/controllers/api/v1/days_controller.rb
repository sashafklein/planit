class Api::V1::DaysController < ApiController
  
  before_action :load_day, only: [:map]

  def map
    error(500, "Bad map-loading params", params) unless @day
    render json: @day
  end

  private

  def load_day
    @day = Day.find(params[:id])
  end
end