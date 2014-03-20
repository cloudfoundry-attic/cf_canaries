require_relative 'spec_helper'

describe InstancePinger do
  subject(:instance_pinger) { InstancePinger.new('fake_url', 4) }

  describe "#pinged_running_ratio" do
    it 'returns ratio of instances seen by pinging versus total number of instances' do
      Net::HTTP.should_receive(:get).exactly(16).times.and_return("1", "2", "3")
      expect(instance_pinger.pinged_running_ratio).to eq 0.75
    end
  end
end