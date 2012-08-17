require 'vcr'

VCR.configure do |vcr|
  vcr.cassette_library_dir     = 'spec/cassettes'
  vcr.default_cassette_options = { record: :none,
                                   match_requests_on: [ :method, :uri, :body ]}
  vcr.hook_into :webmock
  vcr.configure_rspec_metadata!
end

RSpec.configure do |rspec|
  rspec.treat_symbols_as_metadata_keys_with_true_values = true
  rspec.before :each, integration: true do
    VCR.configure do |vcr|
      vcr.allow_http_connections_when_no_cassette = true
    end
  end

  rspec.after :each, integration: true do
    VCR.configure do |vcr|
      vcr.allow_http_connections_when_no_cassette = false
    end
  end
end
