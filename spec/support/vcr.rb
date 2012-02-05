require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.default_cassette_options = { record: :none,
                                 match_requests_on: [ :method, :uri, :body ]}
  c.hook_into :webmock
end

module VCRHelpers
  def expect_cassette_used(&action)
    expect_cassettes_used 1, &action
  end

  def expect_cassettes_used(count, &action)
    original_count = VCR.http_interactions.remaining_unused_interaction_count
    original_count.should > 0
    action.call
    VCR.http_interactions.remaining_unused_interaction_count.
      should eq(original_count - count)
  end
end
