class Api::V1::Users::MarksController < ApiController

  before_action :load_user, only: [:create, :scrape, :mini_scrape, :bucket]
  
  before_action :cors_set_access_control_headers, only: [:scrape, :mini_scrape]
  after_action :cors_set_access_control_headers, only: [:scrape, :mini_scrape]

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
    log msg: "URL: #{params[:url]}"
    scraper = Services::SiteScraper.build(params[:url], params[:page]) || Scrapers::General.new(params[:url], params[:page])
    scraped = Array scraper.data

    log_and_complete(scraped, params[:url], 'scrape')
  end

  def mini_scrape
    return error(404, "User not found") unless @user
    return error(500, "Missing url param") unless params[:url]    

    scraped = JSON.parse params[:scraped]
    
    log msg: "MINI - URL: #{params[:url]}, SCRAPED: #{params[:scraped]}"

    if scraped.is_a?(Hash)
      scraped = scraped[:place] ? [scraped] : [{ place: scraped }]
    end

    log_and_complete(scraped, params[:url], 'mini scrape')
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

  def log_and_complete(scraped, url, action)
    if !good_data?(scraped)
      @user.flags.create!( name: "Scrape and completion failed in #{action}", info: { url: url , data: scraped } )
      return error(417, "Insufficient information")
    end

    log msg: "#{action.upcase} - DELAYING COMPLETION: #{delay?}"
    log msg: "#{action.upcase} - DATA: #{scraped}\n\n"
    Completers::MassCompleter.new(scraped, @user, url).delay_complete!(delay?)
    log msg: "#{action.upcase} - AFTER COMPLETION HAS BEEN BACKGROUNDED"
    success
  end
end