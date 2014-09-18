class Api::V1::BookmarkletsController < ApiController
  def show
    path = File.join Rails.root, 'app', 'assets', 'javascripts', 'api', 'bookmarklets', "#{params[:id]}.coffee"
    if File.exists? path
      js = Uglifier.compile CoffeeScript.compile File.read(path)
      render js: js.gsub("HOSTNAME", request.base_url).gsub("USER_ID", params[:user_id])
    else
      error(500, "No file found at location: #{path}")  
    end
  end
end