require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.default_cassette_options = { record: :none,
                                 match_requests_on: [ :method, :uri, :body ]}
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.before :each, integration: true do
    VCR.configure do |vcr|
      vcr.allow_http_connections_when_no_cassette = true
    end
  end

  c.after :each, integration: true do
    VCR.configure do |vcr|
      vcr.allow_http_connections_when_no_cassette = false
    end
  end
end
