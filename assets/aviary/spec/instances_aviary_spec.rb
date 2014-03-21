require_relative 'spec_helper'

describe InstancesAviary do
  subject(:aviary) do
    described_class.new(
      'fake_target',
      'fake_domain',
      'fake_user',
      'fake_password',
      'fake_org',
      'fake_space',
      'fake_app',
      100)
  end

  let(:client) { double('cfoundry_client', app_by_name: app).as_null_object }
  let(:app) { double('app', total_instances: 100, running_instances: 80, url: 'fake_url') }
  let(:instance_pinger) { double('instance_pinger', running_ratio: 0.25, ping!: 0.25) }

  before do
    allow(InstancePinger).to receive(:new).with('fake_app', 'fake_domain', instance_of(Fixnum)).and_return(instance_pinger)
    allow(CFoundry::Client).to receive(:get).and_return(client)
  end

  describe '#cfoundry_running_ratio' do
    it 'returns the correct ratio' do
      aviary.cfoundry_running_ratio.should == 0.8
    end
  end

  describe '#pinged_running_ratio' do
    it 'delegates to an InstancePinger for its app' do
      expect(aviary.pinged_running_ratio).to eq 0.25
      expect(InstancePinger).to have_received(:new).with('fake_app', 'fake_domain', instance_of(Fixnum))
    end
  end

  describe '#client' do
    it 'creates the client only once' do
      expect(CFoundry::Client).to receive(:get).once
      2.times { aviary.client }
    end
  end

  describe '#ok?' do
    context 'when at least 80% of the instances can be pinged' do
      before do
        allow(instance_pinger).to receive(:running_ratio).and_return(0.80)
      end

      context 'and cloud controller reports at least 80% of the instances are up' do
        it 'is ok' do
          expect(aviary).to be_ok
        end
      end

      context 'but cloud controller reports less than 80% of the instances are up' do
        it 'is not ok' do
          allow(app).to receive(:running_instances).and_return(20)
          expect(aviary).not_to be_ok
        end
      end
    end

    context 'when less than 80% of the instances can be pinged' do
      before do
        allow(instance_pinger).to receive(:running_ratio).and_return(0.10)
      end

      it 'is not ok' do
        expect(aviary).not_to be_ok
      end
    end
  end
end

