require "rspec"
require "rack/test"
require "webmock/rspec"
require "timecop"

require_relative "../lib/instance_pinger"
require_relative "../lib/instances_aviary"
require_relative "../lib/instances_from_cf_aviary"
require_relative "../lib/instances_heartbeats_aviary"
require_relative "../lib/instances_pinged_aviary"
require_relative "../lib/zero_downtime_aviary"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
