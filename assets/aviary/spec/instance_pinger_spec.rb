require_relative 'spec_helper'

describe InstancePinger do
  subject(:instance_pinger) { InstancePinger.new('fake_url', 4) }

  def fake_response(code, body)
    double(Net::HTTPResponse, code: code, body: body)
  end

  def fake_ok(body)
    fake_response('200', body)
  end

  describe '#ping!' do
    it 'returns the ratio of instances seen by pinging to the total number of instances' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'), fake_ok('2'), fake_ok('3'))
      expect(instance_pinger.ping!).to eq 0.75
    end

    it 'sends out 4 pings per instance canary' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'))
      instance_pinger.ping!

      expect(Net::HTTP).to have_received(:get_response).exactly(16).times
    end

    it 'ignores non-200 responses' do
      allow(Net::HTTP).to receive(:get_response).and_return(fake_response('404', 'Not Found'))
      expect(instance_pinger.ping!).to eq 0
    end
  end

  describe '#running_ratio' do
    it 'defaults to 0' do
      expect(instance_pinger.running_ratio).to be 0
    end

    it 'does not ping the instances itself' do
      allow(Net::HTTP).to receive(:get_response)

      instance_pinger.running_ratio

      expect(Net::HTTP).not_to have_received(:get_response)
    end

    context 'when ping! has been called' do
      before do
        allow(Net::HTTP).to receive(:get_response).and_return(fake_ok('1'))
        instance_pinger.ping!
      end

      it 'returns the latest ping! result' do
        expect(instance_pinger.running_ratio).to eq 0.25
      end
    end
  end
end
