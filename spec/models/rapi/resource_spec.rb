require 'spec_helper'

describe F5::Icontrol::RAPI::Resource do
  subject { described_class.new pool, {} }
  describe "#initialize" do
  end

  describe "get attribute" do
    it 'returns an attribute that exists' do
      expect(subject.ipTosToServer).to eq 'pass-through'
    end
  end

  describe "get subcollection" do
    it 'returns an api reference' do
      expect(subject.members).to be_an_instance_of F5::Icontrol::RAPI
    end
  end

  def pool
    JSON.parse '{"kind":"tm:ltm:pool:poolstate","name":"reallybasic","partition":"Common","fullPath":"/Common/reallybasic","generation":845,"selfLink":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic?ver=11.5.1","allowNat":"yes","allowSnat":"yes","ignorePersistedWeight":"disabled","ipTosToClient":"pass-through","ipTosToServer":"pass-through","linkQosToClient":"pass-through","linkQosToServer":"pass-through","loadBalancingMode":"round-robin","minActiveMembers":0,"minUpMembers":0,"minUpMembersAction":"failover","minUpMembersChecking":"disabled","queueDepthLimit":0,"queueOnConnectionLimit":"disabled","queueTimeLimit":0,"reselectTries":0,"slowRampTime":10,"membersReference":{"link":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic/members?ver=11.5.1","isSubcollection":true}}'
  end
end

