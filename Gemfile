source "https://rubygems.org"

ruby "2.2.2"

gem "rails", "4.2.1"

# error reporting
gem "rollbar"
gem "newrelic_rpm"
gem "oink"
gem "informant-rails"
gem "rack-mini-profiler", require: false
gem "rack-timeout"

# emailing
gem "roadie-rails"

# css and page-interactions
gem "bootstrap-sass"
gem "jquery-rails"

# scraping
gem "nokogiri"

# coding efficiency
gem "haml-rails"
gem "coffee-rails"
gem "sass-rails"
gem "uglifier"
gem "draper", require: false
gem "autoprefixer-rails"

# database / server
gem "pg"
gem "delayed_job_active_record"
gem "unicorn"
gem "memoist"
gem "active_model_serializers"
gem "hirefire-resource"

# services
gem "browser"
gem "image_size"
gem "simple_form"
gem "geocoder"
gem "carmen"
gem "httparty"
gem "timezone"
gem "geonames_api"
gem "pusher"

# security
gem "devise"
gem "pundit"

# search
gem "fuzzy-string-match"
gem "friendly_id"

# terminal
gem "colorize"
# gem "rspec-instafail", require: false
# Add to .rspec on reinclusion:
# --require rspec/instafail
# --format RSpec::Instafail

# apis
gem "yelp"

# export
gem "ruby_kml"
gem "pdfkit"
gem "wkhtmltopdf-binary"

# unsure
gem "flutie"
gem "figaro"
gem "activeadmin", github: "activeadmin"
gem "angular-rails-templates"

source "https://rails-assets.org" do
  %w( angular angular-mocks active-support async lodash leaflet angular-leaflet-directive dragula.js momentjs ).each do |lib|
    gem "rails-assets-#{lib}"
  end
end

group :development do
  gem "foreman"
  gem "binding_of_caller"
  gem "bullet"
  gem "better_errors" # disable to run Teaspon JS tests
end

group :development, :test do
  gem "awesome_print"
  gem "byebug"
  gem "pry-rails"
  gem "teaspoon"
end

group :test do
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "timecop"
  gem "webmock"
  gem "vcr"
  gem "shoulda-matchers", require: false
  gem "factory_girl_rails"
  gem "rspec-rails"
  gem "selenium-webdriver"
end

group :staging, :production do
  gem "rails_12factor"
end
