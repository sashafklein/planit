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

gem "haml-rails"
gem 'geocoder'
gem 'rest_client'
gem 'devise'
gem 'friendly_id', '~> 5.0.0'
gem 'rack-mini-profiler'
gem 'active_model_serializers'
gem 'rails-assets'
gem 'angular-rails-templates'

group :assets do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-angular-route'
  gem 'rails-assets-angular-mocks'
  gem 'rails-assets-active-support'
  gem 'rails-assets-async'
  gem 'rails-assets-lodash'
end

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
  gem "rspec-rails", "~> 2.14.0"

  gem 'jasmine'
end

group :test do
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers", require: false
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "newrelic_rpm", ">= 3.7.3"
  gem 'rails_12factor'
end
