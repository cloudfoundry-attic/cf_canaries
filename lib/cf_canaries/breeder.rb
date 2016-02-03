require 'thread'

module CfCanaries
  class Breeder
    def initialize(options)
      @options = options
    end

    def breed(logger, runner)
      logger.info 'targeting and logging in'
      runner.cf!([
        "api",
        @options.target,
        @options.skip_ssl_validation ? "--skip-ssl-validation" : nil
      ].compact.join(' '))
      logger.info "Logging in as '#{@options.username}' user to '#{@options.organization}' org, '#{@options.space}' space."
      runner.cf!("login -u '#{@options.username}' -p '#{@options.password}' -o #{@options.organization} -s #{@options.space}", :skip_logging_command => true, :password=>@options.password)
      logger.info "Succeeded logging in."

      logger.info 'breeding canaries'

      push_zero_downtime_canary(logger, runner)
      push_aviary(logger, runner)
      push_cpu_canary(logger, runner)
      push_disk_canary(logger, runner)
      push_memory_canary(logger, runner)
      push_network_canary(logger, runner)
      push_instances_canary(logger, runner)
      push_long_running_canary(logger, runner)

      logger.info 'TWEET TWEET'
    end

    private

    def push_zero_downtime_canary(logger, runner)
      number_of_canaries = @options.number_of_zero_downtime_apps

      logger.info "pushing #{number_of_canaries} zero-downtime canaries"

      number_of_canaries.times do |i|
        push_app(
          logger, runner, "zero-downtime-canary#{i + 1}", {},
          directory_name: 'zero-downtime/src/zero-downtime',
          memory: '128M'
        )
      end
    end

    def push_aviary(logger, runner)
      env = {
        TARGET: @options.target,
        USERNAME: @options.username,
        PASSWORD: @options.password,
        DOMAIN: @options.app_domain,
        ORG: @options.organization,
        SPACE: @options.space,
        ZERO_DOWNTIME_NUM_INSTANCES: @options.number_of_zero_downtime_apps,
        INSTANCES_CANARY_NUM_INSTANCES: @options.number_of_instances_canary_instances,
      }

      push_app(logger, runner, 'aviary', env)
    end

    def push_cpu_canary(logger, runner)
      push_app(logger, runner, 'cpu', {}, memory: '512M')
    end

    def push_disk_canary(logger, runner)
      push_app(logger, runner, 'disk', {SPACE: '768'}, memory: '512M')
    end

    def push_memory_canary(logger, runner)
      push_app(logger, runner, 'memory', {MEMORY: '112M'})
    end

    def push_network_canary(logger, runner)
      push_app(
        logger, runner, 'network', {},
        memory:         '128M',
        directory_name: 'network/src/network-canary')
    end

    def push_instances_canary(logger, runner)
      push_app(
        logger, runner, 'instances-canary', {
          AVIARY: "aviary.#{@options.app_domain}"
        },
        instances:      @options.number_of_instances_canary_instances,
        memory:         '128M',
        directory_name: 'instances'
      )
    end

    def push_long_running_canary(logger, runner)
      push_app(
        logger, runner, 'long-running-canary', {},
        memory:         '128M',
        directory_name: 'long-running'
      )
    end

    def push_app(logger, runner, name, env = {}, options = {})
      directory_name = options.fetch(:directory_name, name)
      instances = options.fetch(:instances, @options.number_of_instances_per_app)
      memory = options.fetch(:memory, '256M')
      buildpack = options.fetch(:buildpack, '')

      logger.info "pushing #{name} canary"

      if app_exists?(logger, runner, name)
        logger.info 'skipping'
        return
      end

      logger.info 'pushing!'

      command =
        [
          "push #{name}",
          "--no-start",
          "-p #{canary_path(directory_name)}",
          "-n #{name}",
          "-d #{@options.app_domain}",
          "-i #{instances}",
          "-m #{memory}",
          "-b '#{buildpack}'"
        ].join(' ')

      runner.cf!(command)

      if @options.diego
        runner.cf!("set-env #{name} CF_DIEGO_RUN_BETA true")
      end

      env.each do |k, v|
        command = "set-env #{name} #{k} '#{v}'"
        if k == :PASSWORD
          logger.info "Setting environment variable '#{k}' for app '#{name}'."
          runner.cf!(command, :skip_logging_command => true, :hide_command_output => true)
          logger.info "Succeeded setting environment variable."
        else
          runner.cf!(command)
        end
      end

      runner.cf!("start #{name}")
    end

    def canary_path(name)
      File.expand_path(name, canary_base_path)
    end

    def canary_base_path
      File.expand_path('../../assets', File.dirname(__FILE__))
    end

    def app_exists?(logger, runner, name)
      logger.info "checking for app #{name}"

      begin
        runner.cf!("app #{name}")
        true
      rescue RuntimeError => e
        logger.error(e)
        false
      end
    end
  end
end
