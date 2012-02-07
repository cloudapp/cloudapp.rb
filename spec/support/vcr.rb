require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.default_cassette_options = { record: :none,
                                 match_requests_on: [ :method, :uri, :body ]}
  c.hook_into :webmock
end
