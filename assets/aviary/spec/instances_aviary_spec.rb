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

  let(:cf_aviary) { double(InstancesFromCFAviary, ok?: true, running_ratio: 0.95) }
  let(:pinged_aviary) { double(InstancesPingedAviary, ok?: true, running_ratio: 0.85) }

  before do
    allow(InstancesPingedAviary).to receive(:new).with('fake_app', 'fake_domain', instance_of(Fixnum)).and_return(pinged_aviary)
    allow(InstancesFromCFAviary).to receive(:new).and_return(cf_aviary)
  end

  describe '#ok?' do
    it 'creates new pinged and cf aviaries and calls their ok? methods' do
      aviary.ok?
      expect(InstancesPingedAviary).to have_received(:new)
      expect(InstancesFromCFAviary).to have_received(:new)
      expect(pinged_aviary).to have_received(:ok?)
      expect(cf_aviary).to have_received(:ok?)
    end

    context 'when the pinged aviary is ok' do
      context 'and the CF aviary is ok' do
        it 'is ok' do
          expect(aviary).to be_ok
        end
      end

      context 'but the CF aviary is not ok' do
        it 'is not ok' do
          allow(cf_aviary).to receive(:ok?).and_return(false)
          expect(aviary).not_to be_ok
        end
      end
    end

    context 'when the pinged aviary is not ok' do
      before do
        allow(pinged_aviary).to receive(:ok?).and_return(false)
      end

      it 'is not ok' do
        expect(aviary).not_to be_ok
      end

      context 'but the CF aviary is ok' do
        it 'is not ok' do
          expect(aviary).not_to be_ok
        end
      end
    end
  end

  describe '#error_message' do
    it 'reports both the CF and pinged ratios after a check' do
      aviary.ok?
      error_message = aviary.error_message
      expect(error_message).to match(/cfoundry running ratio: 0.95/)
      expect(error_message).to match(/pinged running ratio: 0.85/)
    end
  end

  describe '#cfoundry_running_ratio' do
    it 'returns the running ratio from the CF aviary after a check' do
      allow(cf_aviary).to receive(:running_ratio).and_return(0.90)
      aviary.ok?
      expect(aviary.cfoundry_running_ratio).to eq 0.90
    end
  end

  describe '#pinged_running_ratio' do
    it 'returns the running ratio from the pinged aviary after a check' do
      allow(pinged_aviary).to receive(:running_ratio).and_return(0.70)
      aviary.ok?
      expect(aviary.pinged_running_ratio).to eq 0.70
    end
  end
end

