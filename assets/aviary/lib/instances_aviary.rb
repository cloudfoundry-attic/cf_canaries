require "cfoundry"
require "net/http"
require_relative "instance_pinger"

class InstancesAviary
  def initialize(target, user, password, org, space, app_name)
    @target, @user, @password, @org, @space, @app_name = target, user, password, org, space, app_name
  end

  def client
    @client ||= CFoundry::Client.get(@target).tap do |c|
      c.login(username: @user, password: @password)
      c.current_organization = c.organization_by_name(@org)
      c.current_space = c.space_by_name(@space)
    end
  end

  def error_message
    "Instances canary croaked (cfoundry running ratio: #{cfoundry_running_ratio}%, pinged running ratio: #{pinged_running_ratio}%)"
  end

  def app
    @app ||= client.app_by_name(@app_name)
  end

  def ok?
    cfoundry_running_ratio >= 0.8 && pinged_running_ratio >= 0.8
  end

  def cfoundry_running_ratio
    return app.running_instances.to_f  / app.total_instances
  end

  def pinged_running_ratio
    InstancePinger.new(app.url, app.total_instances).pinged_running_ratio
  end
end
