require "rspec"
require "rack/test"
require "webmock/rspec"
require "timecop"

require_relative "../lib/instances_aviary"
require_relative "../lib/instances_heartbeats_aviary"
require_relative "../lib/zero_downtime_aviary"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end