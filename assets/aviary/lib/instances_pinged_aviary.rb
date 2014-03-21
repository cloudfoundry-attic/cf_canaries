require_relative 'instance_pinger'

class InstancesPingedAviary
  HEALTH_THRESHOLD = 0.8

  def initialize(app, domain, instance_count)
    @instance_pinger = InstancePinger.new(app, domain, instance_count.to_i)
  end

  def ok?
    @instance_pinger.ping!
    @instance_pinger.running_ratio >= HEALTH_THRESHOLD
  end

  def error_message
    "Instances canary croaked (pinged running ratio: #{@instance_pinger.running_ratio})"
  end
end
