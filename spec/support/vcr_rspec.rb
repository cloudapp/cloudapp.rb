require 'support/vcr'

VCR.configure do |c|
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include VCRHelpers
end
