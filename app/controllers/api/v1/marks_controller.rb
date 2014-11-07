class Api::V1::MarksController < ApiController
  
  before_action :load_user, only: [:create, :scrape]
  
  before_action :cors_set_access_control_headers, only: [:scrape]
  after_action :cors_set_access_control_headers, only: [:scrape]

  def create
    return error(404, "User not found") unless @user
    
    completed = Completer.new(params[:mark], @user).complete!
    if completed
      render json: completed, serializer: TotalMarkSerializer
    else
      error(500, "We couldn't find enough information!")
    end
  end

  def scrape
    return error(404, "User not found") unless @user
    scraped = Services::SiteScraper.build(params[:url], params[:page])
    completed = Services::MassCompleter.new(scraped, @user).complete
    render json: completed, each_serializer: TotalMarkSerializer
  end

  private

  def load_user
    @user = User.friendly.find(params[:user_id])
  rescue
    @user = nil
  end

  def mark_params
    params.require(:mark)
  end
end