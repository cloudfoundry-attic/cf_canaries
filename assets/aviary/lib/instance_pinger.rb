require "net/http"

class InstancePinger
  def initialize(url, instance_count)
    @url = url
    @instance_count = instance_count.to_i
  end

  def pinged_running_ratio
    threads = []
    indexes = {}
    mutex = Mutex.new
    (@instance_count * 4).times do
      threads << Thread.new(indexes) do |indexes|
        resp = Net::HTTP.get_response(@url, '/instance-index')

        if resp.code == '200'
          mutex.synchronize { indexes[resp.body] = true }
        end
      end
    end

    threads.each(&:join)

    indexes.size.to_f / @instance_count
  end
end
