require "cfoundry"
require "net/http"
require_relative "instance_pinger"

class InstancesFromCFAviary
  def initialize(target, user, password, org, space, app_name)
    @target = target
    @user, @password, @org, @space = user, password, org, space
    @app_name = app_name
  end

  def client
    @client ||= CFoundry::Client.get(@target).tap do |c|
      c.login(username: @user, password: @password)
      c.current_organization = c.organization_by_name(@org)
      c.current_space = c.space_by_name(@space)
    end
  end

  def error_message
    "Instances canary croaked (cfoundry running ratio: #{cfoundry_running_ratio})"
  end

  def ok?
    cfoundry_running_ratio >= 0.8
  end

  def cfoundry_running_ratio
    app.running_instances.to_f  / app.total_instances
  end

  private

  def app
    @app ||= client.app_by_name(@app_name)
  end
end
