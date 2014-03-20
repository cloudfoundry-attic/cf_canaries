require_relative 'spec_helper'

describe InstancePinger do
  subject(:instance_pinger) { InstancePinger.new('fake_url', 4) }

  before do
    allow(Net::HTTP).to receive(:get).and_return("1", "2", "3")
  end

  describe '#pinged_running_ratio' do
    it 'returns ratio of instances seen by pinging versus total number of instances' do
      expect(instance_pinger.pinged_running_ratio).to eq 0.75
      expect(Net::HTTP).to have_received(:get).exactly(16).times
    end
  end

  describe '#ok?' do
    context 'when more than 80% of the instance canaries report' do
      it 'is ok' do
        allow(Net::HTTP).to receive(:get).and_return('1', '2', '3', '4')
        expect(instance_pinger).to be_ok
      end
    end

    context 'when fewer than 80% of the instance canaries report' do
      it 'is ok' do
        allow(Net::HTTP).to receive(:get).and_return('1', '2')
        expect(instance_pinger).not_to be_ok
      end
    end
  end

  describe '#error_message' do
    it 'returns a message with the pinged running ratio' do
      expect(instance_pinger.error_message).to match(/running ratio: 0.75/)
    end
  end
end