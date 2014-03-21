require "net/http"

class InstancePinger
  attr_reader :running_ratio

  def initialize(app_name, domain, instance_count)
    @url = "#{app_name}.#{domain}"
    @instance_count = instance_count.to_i
    @running_ratio = 0
  end

  def ping!
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

    @running_ratio = indexes.size.to_f / @instance_count
  end
end
