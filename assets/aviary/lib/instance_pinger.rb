require "net/http"

class InstancePinger
  HEALTH_THRESHOLD = 0.8

  def initialize(url, instance_count)
    @url = url
    @instance_count = instance_count.to_i
  end

  def error_message
    "Instances canary croaked (pinged running ratio: #{pinged_running_ratio})"
  end

  def ok?
    pinged_running_ratio >= HEALTH_THRESHOLD
  end

  def pinged_running_ratio
    threads = []
    indexes = {}
    mutex = Mutex.new
    (@instance_count * 4).times do
      threads << Thread.new(indexes) do |indexes|
        index = Net::HTTP.get(@url, '/instance-index')
        mutex.synchronize { indexes[index] = true }
      end
    end

    threads.each(&:join)

    indexes.size.to_f / @instance_count
  end

end