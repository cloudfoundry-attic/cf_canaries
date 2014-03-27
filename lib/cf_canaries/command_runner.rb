module CfCanaries
  class CommandRunner
    EMPTY_ENVIRONMENT = {}.freeze

    def initialize(logger, dry_run, cf_command='gcf')
      @logger = logger
      @dry_run = dry_run
      @cf_command = cf_command
    end

    def cf!(command)
      run!("#{@cf_command} #{command}")
    end

    private

    def run!(command)
      @logger.info(command)

      return if @dry_run

      pid = spawn(command)

      _, status = Process.wait2(pid)

      raise "Command failed: #{command.inspect})" unless status.success?
    end

    def spawn(command)
      Process.spawn(EMPTY_ENVIRONMENT, 'bash', '-c', command)
    rescue => e
      raise "Spawning command failed: #{e.message}\n#{e.backtrace}"
    end
  end
end
