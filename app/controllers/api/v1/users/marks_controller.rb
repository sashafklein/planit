class Api::V1::Users::MarksController < ApiController
  
  before_action :load_user, only: [:create, :scrape, :bucket]
  
  before_action :cors_set_access_control_headers, only: [:scrape]
  after_action :cors_set_access_control_headers, only: [:scrape]

  def create
    return error(404, "User not found") unless @user
    return permission_denied_error unless @user == current_user
    
    mark = Completers::Completer.new(mark_params, @user).complete!

    if mark
      render json: mark, serializer: SearchMarkSerializer
    else
      error(500, "Bookmark completion failed.")
    end
  end

  def scrape
    return error(404, "User not found") unless @user
    return error(500, "Missing url param") unless params[:url]    
    
    # File.open('~log.html', 'w') { |file| file.write(params[:page]) }

    scraper = Services::SiteScraper.build(params[:url], params[:page]) || Scrapers::General.new(params[:url], params[:page])
    scraped = Array scraper.data
    
    if !good_data?(scraped)
      @user.flags.create!( name: 'Scrape and completion failed', info: { url: params[:url] , data: scraped } )
      return error(417, "Insufficient information")
    end 

    Completers::MassCompleter.new(scraped, @user, params[:url]).delay_complete!(delay?)

    head(200)
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

  def delay?
    params.fetch(:delay, true)
  end

  def good_data?(scraped)
    scraped.to_super.any? do |hash| 
      return false unless p = hash.place
      p.locality || p.region || p.nearby.present? || p.country || p.full_address || (p.lat && p.lon) # p.street_address || p.street_addresses.present?
    end
  rescue
    false
  end
end