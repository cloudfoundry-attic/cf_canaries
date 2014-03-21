require "sinatra"
require "cfoundry"
require_relative 'lib/instance_pinger'
require_relative 'lib/instances_aviary'
require_relative 'lib/instances_heartbeats_aviary'
require_relative 'lib/instances_pinged_aviary'
require_relative 'lib/zero_downtime_aviary'

TARGET = ENV['TARGET']
DOMAIN = ENV['DOMAIN']
USERNAME = ENV['USERNAME']
PASSWORD = ENV['PASSWORD']
ORG = ENV['ORG']
SPACE = ENV['SPACE']

INSTANCES_CANARY_NUM_INSTANCES = ENV['INSTANCES_CANARY_NUM_INSTANCES'].to_i
INSTANCES_CANARY_APP_NAME = 'instances-canary'

ZERO_DOWNTIME_NUM_INSTANCES = ENV['ZERO_DOWNTIME_NUM_INSTANCES'].to_i
ZERO_DOWNTIME_APP_NAME = 'zero-downtime-canary'

set :port, ENV["PORT"].to_i

get "/instances_aviary" do
  aviary = InstancesAviary.new(TARGET, DOMAIN, USERNAME, PASSWORD, ORG, SPACE, INSTANCES_CANARY_APP_NAME, INSTANCES_CANARY_NUM_INSTANCES)
  check(aviary)
end

get "/instances_pinged_aviary" do
  aviary = InstancesPingedAviary.new(INSTANCES_CANARY_APP_NAME, DOMAIN, INSTANCES_CANARY_NUM_INSTANCES)
  check(aviary)
end

get "/zero_downtime_aviary" do
  aviary = ZeroDowntimeAviary.new(DOMAIN, ZERO_DOWNTIME_APP_NAME, ZERO_DOWNTIME_NUM_INSTANCES )
  check(aviary)
end

instances_heartbeats_aviary = InstancesHeartbeatsAviary.new(TARGET, USERNAME, PASSWORD, ORG, SPACE, INSTANCES_CANARY_APP_NAME)

put "/instances_heartbeats/:index" do |index|
  instances_heartbeats_aviary.process_heartbeat(index)
end

get "/instances_heartbeats" do
  check(instances_heartbeats_aviary)
end

def check(aviary)
  if aviary.ok?
    "Sing"
  else
    status 500
    body "zero downtime canary croaked (#{aviary.error_message})"
  end
end
