require "cfoundry"
require "net/http"
require_relative "instance_pinger"

class InstancesAviary
  def initialize(target, domain, user, password, org, space, app_name, instance_count)
    @target, @domain = target, domain
    @user, @password, @org, @space = user, password, org, space
    @app_name, @instance_count = app_name, instance_count
  end

  def client
    @client ||= CFoundry::Client.get(@target).tap do |c|
      c.login(username: @user, password: @password)
      c.current_organization = c.organization_by_name(@org)
      c.current_space = c.space_by_name(@space)
    end
  end

  def error_message
    "Instances canary croaked (cfoundry running ratio: #{cfoundry_running_ratio}%, pinged running ratio: #{instance_pinger.running_ratio}%)"
  end

  def ok?
    cfoundry_running_ratio >= 0.8 && pinged_running_ratio >= 0.8
  end

  def cfoundry_running_ratio
    return app.running_instances.to_f  / app.total_instances
  end

  def pinged_running_ratio
    instance_pinger.ping!
    instance_pinger.running_ratio
  end

  private

  def app
    @app ||= client.app_by_name(@app_name)
  end

  def instance_pinger
    @instance_pinger ||= InstancePinger.new(@app_name, @domain, @instance_count)
  end
end
