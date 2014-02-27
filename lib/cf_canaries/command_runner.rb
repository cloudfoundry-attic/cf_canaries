module CfCanaries
  class CommandRunner
    EMPTY_ENVIRONMENT = {}.freeze

    def initialize(logger, dry_run)
      @logger = logger
      @dry_run = dry_run
    end

    def run!(command)
      @logger.info(command)

      return if @dry_run

      pid = spawn(command)

      Process.wait(pid)

      raise "Command failed: #{command.inspect})" unless $?.success?
    end

    def spawn(command)
      Process.spawn(EMPTY_ENVIRONMENT, 'bash', '-c', command)
    rescue => e
      raise "Spawning command failed: #{e.message}\n#{e.backtrace}"
    end
  end
end
