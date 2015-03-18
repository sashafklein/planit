source "https://rubygems.org"
source "https://rails-assets.org"

ruby "2.2.0"

gem "rollbar"
gem "bourbon"
gem "coffee-rails"
gem "delayed_job_active_record"
gem "email_validator"
gem "flutie"
gem "jquery-rails"
gem "neat"
gem "pg"
gem "rack-timeout"
gem "rails", "4.2.0"
gem "recipient_interceptor"
gem "sass-rails"
gem "uglifier"
gem "unicorn"
gem "memoist"

gem "nokogiri"
gem "font-awesome-sass"
gem "image_size"
gem "simple_form"
gem "elasticsearch-rails"
gem "elasticsearch-model"
gem "rspec-instafail", require: false
gem 'roadie-rails'

gem "haml-rails"
gem "geocoder"
gem "carmen"
gem "httparty"
gem "devise"
gem "friendly_id"
gem "rack-mini-profiler", require: false
gem "active_model_serializers"
gem "fuzzy-string-match"
gem "bootstrap-sass"
gem "autoprefixer-rails"
gem "draper", require: false
gem "timezone"
gem "newrelic_rpm"

gem "pundit"
gem "acts-as-taggable-on"

gem "compass"
gem "compass-rails"
gem "colorize"

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
  gem 'better_errors' # disable to run Teaspon JS tests
end

group :development, :test do
  gem "awesome_print"
  gem "byebug"
  gem "dotenv-rails"
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
