require "cfoundry"
require "net/http"
require_relative "instance_pinger"
require_relative "instances_pinged_aviary"
require_relative "instances_from_cf_aviary"

class InstancesAviary
  def initialize(target, domain, user, password, org, space, app_name, instance_count)
    @target, @domain = target, domain
    @user, @password, @org, @space = user, password, org, space
    @app_name, @instance_count = app_name, instance_count
  end

  def error_message
    "Instances canary croaked (cfoundry running ratio: #{cfoundry_running_ratio}, pinged running ratio: #{pinged_running_ratio})"
  end

  def ok?
    @pinged_aviary = InstancesPingedAviary.new(@app_name, @domain, @instance_count)
    @cf_aviary = InstancesFromCFAviary.new(@target, @user, @password, @org, @space, @app_name)
    cf_aviary_ok = @cf_aviary.ok?
    pinged_aviary_ok = @pinged_aviary.ok?
    pinged_aviary_ok && cf_aviary_ok
  end

  def cfoundry_running_ratio
    @cf_aviary.running_ratio
  end

  def pinged_running_ratio
    @pinged_aviary.running_ratio
  end
end
