class Api::V1::Users::MarksController < ApiController
  
  before_action :load_user, only: [:create, :scrape, :bucket]
  
  before_action :cors_set_access_control_headers, only: [:scrape]
  after_action :cors_set_access_control_headers, only: [:scrape]

  def create
    return error(404, "User not found") unless @user

    completed = Services::Completer.new(mark_params, @user).complete!

    render json: completed, serializer: TotalMarkSerializer
  end

  def scrape
    return error(404, "User not found") unless @user
    return error(500, "Missing url param") unless params[:url]

    scraped = Array Services::SiteScraper.build(params[:url], params[:page]).data

    Services::MassCompleter.new(scraped, @user).delay_complete!
    
    render json: { success: true }
  end

  def bucket
    return error(404, "User not found") unless @user

    @marks = @user.marks
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