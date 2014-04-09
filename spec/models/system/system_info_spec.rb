require 'spec_helper'

describe F5::Icontrol::System::SystemInfo, :vcr do
  subject { described_class.new("10.198.4.135", "admin", "admin") }
  it "retrieves the version" do
    expect(subject.get_version).to eq "BIG-IP_v11.3.0"
  end

  it "retrieves the uptime" do
    expect(subject.get_uptime).to eq "425782"
  end
end
