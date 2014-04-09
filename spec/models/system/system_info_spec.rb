require 'spec_helper'

describe F5::Icontrol::System::SystemInfo, :vcr do
  subject { described_class.new("10.198.4.135", "admin", "admin") }

  describe "#respond_to?" do
    it "supports get_version" do
      expect(subject.respond_to? :get_version).to be_true
    end

    it "supports get_uptime" do
      expect(subject.respond_to? :get_uptime).to be_true
    end

    it "does not support buy cisco" do
      expect(subject.respond_to? :buy_cisco).to be_false
    end
  end

  it "retrieves the version" do
    expect(subject.get_version).to eq "BIG-IP_v11.3.0"
  end

  it "retrieves the uptime" do
    expect(subject.get_uptime).to eq "425782"
  end
end
