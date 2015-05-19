ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'

require "shoulda/matchers"
require "webmock/rspec"
require 'vcr'
require 'factory_girl'
require 'formulaic'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.after(:each, :type => :feature) do |example|
    puts "'#{example.description}' failed. Page saved to #{save_page}" if example.exception
  end

  config.include Features, type: :feature
  config.include Features, type: :request
  config.include Controllers, type: :controller
  config.include Mock
  config.include Universal
  config.include Formulaic::Dsl, type: :feature
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

Capybara.register_driver :chrome do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = (Env.test_timeout || 20).to_i
  Capybara::Selenium::Driver.new(app, browser: :chrome, http_client: client)
end

Capybara.javascript_driver = :chrome

if ENV['CIRCLE_ARTIFACTS']
  Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS']
end

WebMock.disable_net_connect!(allow_localhost: true)