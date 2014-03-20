require "net/http"

class InstancePinger
  def initialize(url, instance_count)
    @url = url
    @instance_count = instance_count
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