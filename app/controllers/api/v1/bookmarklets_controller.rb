class Api::V1::BookmarkletsController < ApiController
  
  # Seems like both were necessary, for both pre-flight and actual requests
  before_filter :cors_set_access_control_headers, only: [:script, :view]
  after_filter :cors_set_access_control_headers, only: [:script, :view]

  def script
    path = File.join Rails.root, 'app', 'assets', 'javascripts', 'api', 'bookmarklets', "base.coffee"
    if File.exists? path

      js = CoffeeScript.compile File.read(path)
          .gsub("HOSTNAME", request.base_url)
          .gsub("USER_ID", params[:user_id])

      complete_js = Uglifier.compile js
            
      render js: complete_js
    else
      error(500, "No file found at location: #{path}")  
    end
  end

  def view
    render 'api/v1/bookmarklets/base', layout: false
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
end