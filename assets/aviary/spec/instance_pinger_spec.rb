require_relative 'spec_helper'

describe InstancePinger do
  subject(:instance_pinger) { InstancePinger.new('fake_url', 4) }

  def fake_response(code, body)
    double(Net::HTTPResponse, code: code, body: body)
  end

  def fake_ok(body)
    fake_response('200', body)
  end

  describe '#pinged_running_ratio' do
    it 'returns the ratio of instances seen by pinging to the total number of instances' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'), fake_ok('2'), fake_ok('3'))
      expect(instance_pinger.pinged_running_ratio).to eq 0.75
    end

    it 'sends out 4 pings per instance canary' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'))
      instance_pinger.pinged_running_ratio

      expect(Net::HTTP).to have_received(:get_response).exactly(16).times
    end

    it 'ignores non-200 responses' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_response('404', 'Not Found'))
      expect(instance_pinger.pinged_running_ratio).to eq 0
    end
  end

  describe '#ok?' do
    context 'when more than 80% of the instance canaries report' do
      it 'is ok' do
        allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'), fake_ok('2'), fake_ok('3'), fake_ok('4'))
        expect(instance_pinger).to be_ok
      end
    end

    context 'when fewer than 80% of the instance canaries report' do
      it 'is ok' do
        allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'), fake_ok('2'))
        expect(instance_pinger).not_to be_ok
      end
    end
  end

  describe '#error_message' do
    it 'returns a message with the pinged running ratio' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'), fake_ok('2'))
      expect(instance_pinger.error_message).to match(/running ratio: 0.5/)
    end
  end
end