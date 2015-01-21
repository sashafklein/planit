ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

require "rspec/rails"
require "shoulda/matchers"
require "webmock/rspec"
require 'vcr'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

module Features
  include Warden::Test::Helpers
  Warden.test_mode!
  
  def sign_in(user)
    login_as(user, scope: :user)
  end
end

module Controllers
  def response_body
    body = JSON.parse(response.body)
    body.is_a?(Hash) ? body.to_sh : body.map(&:to_sh)
  end
end

module Mock
  def disable_webmock(&block)
    WebMock.disable!
    yield
    WebMock.enable!
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Features, type: :feature
  config.include Controllers, type: :controller
  config.include Mock
  config.include Formulaic::Dsl, type: :feature
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.use_transactional_fixtures = false
end

RSpec::Matchers.define :hash_eq do |expected|
  match do |actual|
    actual.recursive_symbolize_keys == expected.recursive_symbolize_keys
  end
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
