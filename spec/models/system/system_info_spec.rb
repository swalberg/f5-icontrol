require 'spec_helper'

describe F5::Icontrol::System::SystemInfo, :vcr do
  it "retrieves the version" do
    bigip = described_class.new("10.198.4.135", "admin", "admin")

    expect(bigip.get_version).to eq "BIG-IP_v11.3.0"
  end
end
