require "net/http"

class InstancePinger
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def pinged_running_ratio
    threads = []
    indexes = {}
    mutex = Mutex.new
    url = app.url
    num_instances = app.total_instances
    (num_instances * 4).times do
      threads << Thread.new(indexes) do |indexes|
        index = Net::HTTP.get(url, '/instance-index')
        mutex.synchronize { indexes[index] = true }
      end
    end

    threads.each(&:join)

    indexes.size.to_f / num_instances
  end

end