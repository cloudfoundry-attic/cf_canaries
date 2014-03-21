require_relative 'instance_pinger'

class InstancesPingedAviary
  HEALTH_THRESHOLD = 0.8

  def initialize(app, domain, instance_count)
    url = "#{app}.#{domain}"
    @instance_pinger = InstancePinger.new(url, instance_count.to_i)
  end

  def ok?
    @instance_pinger.pinged_running_ratio >= HEALTH_THRESHOLD
  end

  def error_message
    "Instances canary croaked (pinged running ratio: #{@instance_pinger.pinged_running_ratio})"
  end
end
