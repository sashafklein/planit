VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.configure_rspec_metadata!
  c.ignore_hosts '127.0.0.1', 'localhost:3000'

  c.default_cassette_options = { record: :new_episodes } # Enable when making API-heavy changes
end