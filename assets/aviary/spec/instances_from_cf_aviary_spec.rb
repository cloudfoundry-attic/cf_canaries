require_relative 'spec_helper'

describe InstancesFromCFAviary do
  subject(:aviary) do
    described_class.new(
      'fake_target',
      'fake_user',
      'fake_password',
      'fake_org',
      'fake_space',
      'fake_app')
  end

  let(:client) { double('cfoundry_client', app_by_name: app).as_null_object }
  let(:app) { double('app', total_instances: 100, running_instances: 80) }

  before do
    allow(CFoundry::Client).to receive(:get).and_return(client)
  end

  describe '#cfoundry_running_ratio' do
    it 'returns the expected ratio' do
      expect(aviary.cfoundry_running_ratio).to eq 0.8
    end
  end

  describe '#client' do
    it 'creates the client only once' do
      expect(CFoundry::Client).to receive(:get).once
      2.times { aviary.client }
    end
  end

  describe '#ok?' do
    context 'when cloud controller reports at least 80% of the instances are up' do
      it 'is ok' do
        expect(aviary).to be_ok
      end
    end

    context 'when cloud controller reports less than 80% of the instances are up' do
      it 'is not ok' do
        allow(app).to receive(:running_instances).and_return(20)
        expect(aviary).not_to be_ok
      end
    end
  end

  describe '#error_message' do
    it 'returns a message with the cfoundry running ratio' do
      expect(aviary.error_message).to match(/running ratio: 0.8/)
    end
  end
end

