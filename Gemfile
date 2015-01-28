source "https://rubygems.org"
source 'https://rails-assets.org'

ruby "2.2.0"

gem "airbrake"
gem "bourbon"
gem "coffee-rails"
gem "delayed_job_active_record"
gem "email_validator"
gem "flutie"
gem "jquery-rails"
gem "neat"
gem "pg"
gem "rack-timeout"
gem "rails"
gem "recipient_interceptor"
gem "sass-rails"
gem "simple_form"
gem "title"
gem "uglifier"
gem "unicorn"

gem 'nokogiri'
gem 'font-awesome-sass'
gem 'image_size'

gem "haml-rails"
gem 'geocoder'
gem 'carmen'
gem 'httparty'
gem 'devise'
gem 'friendly_id'
gem 'rack-mini-profiler', require: false
gem 'active_model_serializers'
gem 'fuzzy-string-match'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'
gem 'draper', require: false
gem 'timezone'
gem 'newrelic_rpm'

gem 'pundit'

gem "compass"
gem "compass-rails"

source 'https://rails-assets.org' do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-angular-route'
  gem 'rails-assets-angular-mocks'
  gem 'rails-assets-active-support'
  gem 'rails-assets-async'
  gem 'rails-assets-lodash'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-requirejs'
  gem 'rails-assets-sinon'
  # gem 'rails-assets-leaflet.markercluster'
end

group :development do
  gem "foreman"
  gem "spring"
  gem "spring-commands-rspec"
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'bullet'
  # gem 'thin'
end

group :development, :test do
  gem "awesome_print"
  gem "byebug"
  gem "dotenv-rails"
  gem "pry-rails"
end

group :test do
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "timecop"
  gem "webmock"
  gem 'vcr'
  gem 'shoulda-matchers', require: false
  gem "factory_girl_rails"

  gem "rspec-rails"
  gem "jasmine-rails"
  gem 'jasmine-headless-webkit'
  gem 'guard-jasmine'
  gem 'rails-assets-rosie'
  gem "sinon-rails"
end

group :staging, :production do
  # gem "newrelic_rpm", ">= 3.7.3"
  gem 'rails_12factor'
end
