class Api::V1::BookmarkletsController < ApiController
  
  # Seems like both were necessary, for both pre-flight and actual requests
  before_filter :cors_set_access_control_headers, only: [:script, :test, :report_error]
  after_filter :cors_set_access_control_headers, only: [:script, :test, :report_error]
  before_filter :allow_iframe_requests, only: [:test]

  def script
    return permission_denied_error unless params[:user_id]

    path = File.join Rails.root, 'app', 'assets', 'javascripts', 'api', 'bookmarklets', "bookmarklet.coffee"
    if File.exists? path

      js = CoffeeScript.compile File.read(path)
          .gsub("HOSTNAME", request.base_url)
          .gsub("USER_ID", params[:user_id])
          .gsub(/["']ASSET_PATH\/(.*?)["']/) { "\"#{ asset_path($1) }\"" }

      complete_js = Uglifier.compile js
            
      render js: complete_js
    else
      error(500, "No file found at location: #{path}")  
    end
  end

  def test
    scraped_sources = Source.for_url_and_type(params[:url], 'Mark').includes(:object)
    if scraped_sources.any?
      source = sort_by_object_place_id(scraped_sources).first
      mark = Mark.create_for_user_from_source! User.friendly.find( params[:user_id] ), source, params[:url]
      render json: { mark_id: mark.id , place_id: mark.place_id }
    else
      render json: { success: false }
    end
  end

  def report_error
    AdminMailer.bookmarklet_failure(params[:user_id], params[:url]).deliver_later
    head(200)
  end

  private

  def specific_file(web_url)
    base_path = File.join Rails.root, 'app', 'assets', 'javascripts', 'api', 'bookmarklets'
    file_path = "#{base_path}/#{file_name(web_url)}"
    if File.exists? file_path
      Uglifier.compile CoffeeScript.compile File.read file_path
    else
      Uglifier.compile CoffeeScript.compile File.read "#{base_path}/manual.coffee"
    end
  end

  def file_name(web_url)
    web_url = web_url.split('www.')[1] if web_url.include? 'www.'
    web_url.split('.')[0] + '.coffee'
  end

  def sort_by_object_place_id(sources)
    sources.sort_by{ |s| s.object.place_id || 0 }.reverse
  end

  def asset_path(path)
    ActionController::Base.helpers.asset_url(path)
  end
end