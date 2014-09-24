require 'f5/icontrol'
require 'vcr'

RSpec.configure do |c|
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into             :webmock
  c.default_cassette_options = { :record => :new_episodes }
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = false
end
