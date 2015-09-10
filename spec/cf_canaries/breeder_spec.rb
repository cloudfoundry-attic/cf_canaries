require 'spec_helper'
require 'cf_canaries/breeder'
require 'cf_canaries/cli'

module CfCanaries
  describe Breeder do
    let(:options) do
      Cli::Options.new.tap do |o|
        o.target = 'some-target'
        o.username = 'username'
        o.password = 'password'
        o.organization = 'canary-org'
        o.space = 'canary-space'
        o.number_of_zero_downtime_apps = 2
        o.app_domain = 'app-domain'
        o.number_of_instances_canary_instances = 3
        o.number_of_instances_per_app = 4
      end
    end

    subject(:breeder) { described_class.new(options) }

    describe '#breed' do
      let(:runner) { double(:runner, cf!: nil) }
      let(:logger) { double(:logger).as_null_object }

      it 'targets the provided api target' do
        expect(runner).to receive(:cf!).with('api some-target')
        breeder.breed(logger, runner)
      end

      it 'logs in and targets the specified organization and space' do
        expect(runner).to receive(:cf!).with("login -u 'username' -p 'password' -o canary-org -s canary-space", :skip_logging_command => true)
        breeder.breed(logger, runner)
      end

      context 'when skipping SSL validation' do
        before do
          options.skip_ssl_validation = true
        end

        it 'provides the skip-ssl-validation flag to the CLI when logging in' do
          expect(runner).to receive(:cf!).with("api some-target --skip-ssl-validation")
          breeder.breed(logger, runner)
        end
      end

      def self.it_pushes_an_app_if_it_does_not_exist(app_name, instances)
        context 'when app exists?' do
          before do
            expect(runner).to receive(:cf!).with("app #{app_name}")
          end

          it 'does not push a an app' do
            expect(runner).to_not receive(:cf!).with(/push #{app_name}/)
            breeder.breed(logger, runner)
          end
        end

        context 'when app does not exist' do
          before do
            expect(runner).to receive(:cf!).with("app #{app_name}").and_raise
          end

          it 'pushes an app' do
            expected_command = /push #{app_name} --no-start -p .*\/assets\/.* -n #{app_name} -d app-domain -i #{instances}/
            expect(runner).to receive(:cf!).with(expected_command)
            breeder.breed(logger, runner)
          end

          context 'when using diego' do
            before { options.diego = true }

            it 'sets the CF_DIEGO_RUN_BETA environment variable for the app' do
              expect(runner).to receive(:cf!).with(/push/)
              expect(runner).to receive(:cf!).with(/set-env #{app_name} CF_DIEGO_RUN_BETA true/)
              breeder.breed(logger, runner)
            end
          end

          context 'when not using diego' do
            it 'does not set the CF_DIEGO_RUN_BETA environment variable' do
              expect(runner).not_to receive(:cf!).with(/DIEGO/)
              breeder.breed(logger, runner)
            end
          end
        end
      end

      describe 'zero downtime canary' do
        it_pushes_an_app_if_it_does_not_exist('zero-downtime-canary1', 4)
        it_pushes_an_app_if_it_does_not_exist('zero-downtime-canary2', 4)
      end

      describe 'aviary' do
        it_pushes_an_app_if_it_does_not_exist('aviary', 4)

        context 'when app does not exist' do
          before do
            expect(runner).to receive(:cf!).with('app aviary').and_raise
          end

          it 'sets TARGET environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary TARGET/)
            breeder.breed(logger, runner)
          end

          it 'sets USERNAME environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary USERNAME/)
            breeder.breed(logger, runner)
          end

          it 'sets PASSWORD environment variable silently' do
            expect(runner).to receive(:cf!).with(/set-env aviary PASSWORD/, :skip_logging_command => true, :hide_command_output => true)
            breeder.breed(logger, runner)
          end

          it 'sets DOMAIN environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary DOMAIN/)
            breeder.breed(logger, runner)
          end

          it 'sets ORG environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary ORG/)
            breeder.breed(logger, runner)
          end

          it 'sets SPACE environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary SPACE/)
            breeder.breed(logger, runner)
          end

          it 'sets ZERO_DOWNTIME_NUM_INSTANCES environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary ZERO_DOWNTIME_NUM_INSTANCES/)
            breeder.breed(logger, runner)
          end

          it 'sets INSTANCES_CANARY_NUM_INSTANCES environment variable normally' do
            expect(runner).to receive(:cf!).with(/set-env aviary INSTANCES_CANARY_NUM_INSTANCES/)
            breeder.breed(logger, runner)
          end
        end
      end

      describe 'cpu canary' do
        it_pushes_an_app_if_it_does_not_exist('cpu', 4)
      end

      describe 'disk canary' do
        it_pushes_an_app_if_it_does_not_exist('disk', 4)
      end

      describe 'memory canary' do
        it_pushes_an_app_if_it_does_not_exist('memory', 4)
      end

      describe 'network canary' do
        it_pushes_an_app_if_it_does_not_exist('network', 4)
      end

      describe 'instances canary' do
        it_pushes_an_app_if_it_does_not_exist('instances-canary', 3)
      end

      describe 'long-running canary' do
        it_pushes_an_app_if_it_does_not_exist('long-running-canary', 4)
      end
    end
  end
end
