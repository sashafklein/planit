ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

require "rspec/rails"
require "shoulda/matchers"
require "webmock/rspec"
require 'vcr'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Features, type: :feature
  config.include Formulaic::Dsl, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.use_transactional_fixtures = false
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.configure_rspec_metadata!
  c.ignore_hosts '127.0.0.1', 'localhost:3000'
end

ActiveRecord::Migration.maintain_test_schema!
Capybara.javascript_driver = :webkit
WebMock.disable_net_connect!(allow_localhost: true)
