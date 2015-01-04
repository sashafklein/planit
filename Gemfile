source "https://rubygems.org"
source 'https://rails-assets.org'

ruby "2.1.2"

gem "airbrake"
gem "bourbon", "~> 3.2.1"
gem "coffee-rails"
gem "delayed_job_active_record"
gem "email_validator"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem "neat", "~> 1.5.1"
gem "pg"
gem "rack-timeout"
gem "rails", "4.1.4"
gem "recipient_interceptor"
gem "sass-rails", "~> 4.0.3"
gem "simple_form"
gem "title"
gem "uglifier"
gem "unicorn"

gem 'nokogiri'
gem 'font-awesome-sass'

gem "haml-rails"
gem 'geocoder'
gem 'carmen'
gem 'httparty'
gem 'devise'
gem 'friendly_id', '~> 5.0.0'
gem 'rack-mini-profiler'
gem 'active_model_serializers'
gem 'fuzzy-string-match'
gem 'bootstrap-sass', '~> 3.3.1'
gem 'autoprefixer-rails'
gem 'draper'
gem 'timezone'

gem "compass"
gem "compass-rails"

gem 'rails-assets-angular'
gem 'rails-assets-angular-resource'
gem 'rails-assets-angular-route'
gem 'rails-assets-angular-mocks'
gem 'rails-assets-active-support'
gem 'rails-assets-async'
gem 'rails-assets-lodash'
gem 'rails-assets-leaflet'
gem 'rails-assets-sinon'
gem 'rails-assets-jasmine-sinon'
gem 'rails-assets-rosie'
gem 'rails-assets-requirejs'
# gem 'rails-assets-leaflet.markercluster'

group :development do
  gem "foreman"
  gem "spring"
  gem "spring-commands-rspec"
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'bullet'
end

group :development, :test do
  gem "awesome_print"
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_girl_rails"
  gem "pry-rails"
  gem "rspec-rails"
  gem "jasmine-rails"
  gem 'jasmine-headless-webkit'
  gem 'guard-jasmine'
  gem "sinon-rails"
end

group :test do
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers", require: false
  gem "timecop"
  gem "webmock"

  gem 'vcr'
  gem 'jasmine'
end

group :staging, :production do
  gem "newrelic_rpm", ">= 3.7.3"
  gem 'rails_12factor'
end
