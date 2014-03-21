require_relative 'spec_helper'

describe InstancesPingedAviary do
  subject(:aviary) { InstancesPingedAviary.new('fake_app', 'fake_domain', 4) }
  let(:pinger) { double(InstancePinger) }

  before do
    allow(InstancePinger).to receive(:new).and_return(pinger)
    allow(pinger).to receive(:ping!)
  end

  describe '#ok?' do
    it 'tells the pinger to ping!' do
      allow(pinger).to receive(:pinged_running_ratio).and_return(0.8)
      expect(pinger).to receive(:ping!)
      aviary.ok?
    end

    context 'when more than 80% of the instance canaries report' do
      it 'is ok' do
        expect(pinger).to receive(:pinged_running_ratio).and_return(0.8)
        expect(aviary).to be_ok
      end
    end

    context 'when fewer than 80% of the instance canaries report' do
      it 'is not ok' do
        expect(pinger).to receive(:pinged_running_ratio).and_return(0.2)
        expect(aviary).not_to be_ok
      end
    end
  end

  describe '#error_message' do
    it 'returns a message with the pinged running ratio' do
      expect(pinger).to receive(:pinged_running_ratio).and_return(0.8)
      expect(aviary.error_message).to match(/running ratio: 0.8/)
    end
  end
end
