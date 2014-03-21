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
    it 'returns a message with the latest  running ratio' do
      aviary.check_cf_status!
      expect(aviary.error_message).to match(/running ratio: 0.8/)
    end
  end

  describe '#running_ratio' do
    it 'defaults to 0' do
      expect(aviary.running_ratio).to eq 0
    end

    it 'returns the running ratio from the latest Cloud Foundry lookup' do
      aviary.check_cf_status!
      expect(aviary.running_ratio).to eq 0.8
    end

    it 'is not updated without calling check_cf_status! again' do
      aviary.check_cf_status!
      expect(aviary.running_ratio).to eq 0.8
      allow(app).to receive(:running_instances).and_return(50)
      expect(aviary.running_ratio).to eq 0.8
    end
  end

  describe '#check_cf_status!' do
    it 'returns the running ratio from the Cloud Foundry lookup' do
      expect(aviary.check_cf_status!).to eq 0.8
    end
  end

  describe '#client' do
    it 'creates the client only once' do
      expect(CFoundry::Client).to receive(:get).once
      2.times { aviary.client }
    end
  end
end

