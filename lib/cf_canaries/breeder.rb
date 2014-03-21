require 'thread'

module CfCanaries
  GO_BUILDPACK='git://github.com/vito/heroku-buildpack-go.git'

  class Breeder
    def initialize(options)
      @options = options
    end

    def breed(logger, runner)
      logger.info 'targeting and logging in'
      runner.run!("gcf api #{@options.target}")
      runner.run!("gcf login -u '#{@options.username}' -p '#{@options.password}' -o #{@options.organization} -s #{@options.space}")

      logger.info 'breeding canaries'

      push_zero_downtime_canary(logger, runner)
      push_aviary(logger, runner)
      push_cpu_canary(logger, runner)
      push_disk_canary(logger, runner)
      push_memory_canary(logger, runner)
      push_network_canary(logger, runner)
      push_instances_canary(logger, runner)

      logger.info 'TWEET TWEET'
    end

    private

    def push_zero_downtime_canary(logger, runner)
      number_of_canaries = @options.number_of_zero_downtime_apps

      logger.info "pushing #{number_of_canaries} zero-downtime canaries"

      number_of_canaries.times do |i|
        push_app(logger, runner, "zero-downtime-canary#{i + 1}", {},
                 directory_name: 'zero-downtime',
                 buildpack: GO_BUILDPACK)
      end
    end

    def push_aviary(logger, runner)
      env = {
        TARGET: @options.target,
        USERNAME: @options.username,
        PASSWORD: @options.password,
        DOMAIN: @options.app_domain,
        ZERO_DOWNTIME_NUM_INSTANCES: @options.number_of_zero_downtime_apps,
        INSTANCES_CANARY_NUM_INSTANCES: @options.number_of_instances_canary_instances,
      }

      push_app(logger, runner, 'aviary', env)
    end

    def push_cpu_canary(logger, runner)
      push_app(logger, runner, 'cpu', {}, memory: '512M')
    end

    def push_disk_canary(logger, runner)
      push_app(logger, runner, 'disk', {SPACE: '768'}, memory: '2G')
    end

    def push_memory_canary(logger, runner)
      push_app(logger, runner, 'memory', {MEMORY: '112M'})
    end

    def push_network_canary(logger, runner)
      push_app(logger, runner, 'network', {}, buildpack: GO_BUILDPACK)
    end

    def push_instances_canary(logger, runner)
      push_app(
        logger, runner, 'instances-canary', {},
        instances: @options.number_of_instances_canary_instances,
        memory: '128M',
        directory_name: 'instances'
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
          "gcf push #{name} --no-start",
          "-p #{canary_path(directory_name)}",
          "-n #{name} -d #{@options.app_domain}",
          "-i #{instances} -m #{memory}",
          "-b '#{buildpack}'"
        ].join(' ')

      runner.run!(command)

      env.each do |k, v|
        runner.run!("gcf set-env #{name} #{k} '#{v}'")
      end
      runner.run!("gcf start #{name}")
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
        runner.run!("gcf app #{name}")
        true
      rescue RuntimeError => e
        logger.error(e)
        false
      end
    end
  end
end
