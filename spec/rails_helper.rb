# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'


# require "shoulda/matchers"
require "webmock/rspec"
require 'vcr'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.after(:each, :type => :feature) do |example|
    puts "'#{example.description}' failed. Page saved to #{save_page}" if example.exception
  end

  config.include Features, type: :feature
  config.include Controllers, type: :controller
  config.include Mock
  # config.include Formulaic::Dsl, type: :feature
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  # To skip Features on CircleCI
  # if ENV['CIRCLE_ARTIFACTS']
  #   config.filter_run_excluding type: :feature
  # end
end

# Capybara.javascript_driver = :webkit

if ENV['CIRCLE_ARTIFACTS']
  Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS']
end

# WebMock.disable_net_connect!(allow_localhost: true)