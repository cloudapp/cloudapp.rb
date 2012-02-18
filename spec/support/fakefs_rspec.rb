require 'fakefs/spec_helpers'

RSpec.configure do |c|
  c.include FakeFS::SpecHelpers, fakefs: true
end
