source "https://rubygems.org"
source "https://rails-assets.org"

ruby "2.2.0"

gem "rails", "4.2.0"

# error reporting
gem "rollbar"
gem "newrelic_rpm"
gem "oink"
gem "informant-rails"
gem "rack-mini-profiler", require: false
gem "rack-timeout"

# emailing
gem "recipient_interceptor"
gem "email_validator"
gem "roadie-rails"

# css and page-interactions
gem "font-awesome-sass"
gem "bootstrap-sass"
gem "jquery-rails"
gem "compass"
gem "compass-rails"
gem "bourbon"
gem "neat"

# scraping
gem "nokogiri"

# coding efficiency
gem "haml-rails"
gem "coffee-rails"
gem "sass-rails"
gem "uglifier"
gem "draper", require: false
gem "autoprefixer-rails" # in-use & non-overlapping to compass?

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

# security
gem "devise"
gem "pundit"

# search
gem "elasticsearch-rails"
gem "elasticsearch-model"
gem "bonsai-elasticsearch-rails"
gem "fuzzy-string-match"
gem "friendly_id"
gem "acts-as-taggable-on" # not using
gem "select2-rails"

# terminal
gem "colorize"
gem "rspec-instafail", require: false

# apis
gem "foursquare2"
gem "yelp"

# export
gem "ruby_kml"
gem "pdfkit"
gem "wkhtmltopdf-binary"

# unsure
gem "flutie"
gem "figaro"
gem 'activeadmin', github: 'activeadmin'

source "https://rails-assets.org" do
  gem "rails-assets-angular"
  gem "rails-assets-angular-mocks"
  gem "rails-assets-active-support"
  gem "rails-assets-async"
  gem "rails-assets-lodash"
  gem "rails-assets-leaflet"
  gem "rails-assets-angular-leaflet-directive"
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
