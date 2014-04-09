require 'spec_helper'

describe F5::Icontrol::LocalLB::Pool, :vcr do
  subject { described_class.new("10.198.4.135", "admin", "admin") }

  describe "#respond_to?" do
    it "supports create_v2" do
      expect(subject.respond_to? :create_v2).to be_true
    end

    it "does not support buy cisco" do
      expect(subject.respond_to? :buy_cisco).to be_false
    end
  end

  it "creates a pool" do
    #<hosts s:type="A:Array" A:arrayType="iControl:System.CPUUsageExtended[0]"/>
    # Common.AddressPortSequenceSequence"

    expect(subject.create_v2(pool_names: {item: ['test_pool']},
                             lb_methods: {item: ["LB_METHOD_OBSERVED_MEMBER"] },
                             members: [ { address: "10.1.1.1", port: "80" } ]
                            )
          ).to be_nil
  end
end
