require 'spec_helper'
require 'cf_canaries/command_runner'

module CfCanaries
  describe CommandRunner do
    let(:dry_run) { false }
    let(:logger) { double('Logger', info: nil) }
    subject(:command_runner) { CommandRunner.new(logger, dry_run) }

    let(:command) { 'echo "Hello"' }

    before do
      allow(Process).to receive(:spawn).and_return(1234)
      allow(Process).to receive(:wait2).with(1234)
    end

    describe "#run!" do
      it "logs the command and waits on the spawned process" do
        expect(logger).to receive(:info).with(command)
        expect(Process).to receive(:wait2).and_return([1234, double('Process::Status', success?: true)])

        command_runner.run!(command)
      end

      context "running in dry_run mode" do
        let(:dry_run) { true }

        it "logs the command but does not run it" do
          expect(logger).to receive(:info).with(command)
          expect(Process).not_to receive(:spawn)
          expect(Process).not_to receive(:wait2)

          command_runner.run!(command)
        end
      end

      context "when the command fails" do
        it "logs the command but does not run it" do
          expect(Process).to receive(:wait2).and_return([1234, double('Process::Status', success?: false)])

          expect { command_runner.run!(command) }.to raise_error
        end
      end
    end
  end
end