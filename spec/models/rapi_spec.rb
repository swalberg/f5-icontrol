require 'spec_helper'

describe F5::Icontrol::RAPI do
  let(:host) { 'somehost' }
  let(:username) { 'me' }
  let(:password) { 'secret' }
  let(:base64) { Base64.encode64("#{username}:#{password}") }

  let(:baseurl) { "https://#{host}" }

  before(:all) { VCR.turn_off! }

  subject { F5::Icontrol::RAPI.new(username: username, password: password, host: host) }

  describe "asking for a collection" do
    context "collections" do
      it "calls the url based on the method chain" do
        stub_request(:get, "#{baseurl}/foo/bar/").
          to_return(body: pool_collection)
        subject.foo.bar.get_collection
        expect(WebMock).to have_requested(:get, "#{baseurl}/foo/bar/")
      end

      it "returns an array of resources" do
        stub_request(:get, "#{baseurl}/foo/bar/").
          to_return(body: pool_collection)

        bars = subject.foo.bar.get_collection

        expect(bars).to be_an_instance_of(Array)
        expect(bars.first).to be_an_instance_of(F5::Icontrol::RAPI::Resource)
      end

      it "converts underscores to dashes in the call" do
        stub_request(:get, "#{baseurl}/foo-bar/").
          to_return(body: pool_collection)

        subject.foo_bar.get_collection

        expect(WebMock).to have_requested(:get, "#{baseurl}/foo-bar/")
      end

      it "preserves underscores in pool names" do
        stub_request(:get, "#{baseurl}/pool/foo_bar").
          to_return(body: pool_collection)

        subject.pool.load('foo_bar')

        expect(WebMock).to have_requested(:get, "#{baseurl}/pool/foo_bar")
      end

      it "understands `each` implicitly calls `get_collection`" do
        stub_request(:get, "#{baseurl}/foo/bar/").
          to_return(body: pool_collection)

        bars = subject.foo.bar.each

        expect(bars).to be_an_instance_of(Enumerator)
      end

      it "handles a block passed to an enumerable method" do
        stub_request(:get, "#{baseurl}/foo/bar/").
          to_return(body: pool_collection)

        pools = subject.foo.bar.map(&:name)

        expect(pools).to eq %w{reallybasic reallybasic2}
      end
    end

    context "subcollections" do
      it "resolves the url based on the method chain and object id" do
        stub_request(:get, "#{baseurl}/mgmt/tm/ltm/pool/").
          to_return(body: pool_collection)

        pools = subject.mgmt.tm.ltm.pool.get_collection

        stub_request(:get, "#{baseurl}/mgmt/tm/ltm/pool/~Common~reallybasic/members/").
          to_return(body: pool_collection)

        pool = pools.first.members.get_collection

        expect(WebMock).to have_requested(:get, "#{baseurl}/mgmt/tm/ltm/pool/~Common~reallybasic/members/")
      end

    end
  end

  describe 'creating a new resource' do
    before do
      stub_request(:post, "#{baseurl}/mgmt/tm/ltm/pool").
        with(body: /"name":"foobar"/, headers: { "Content-Type" => "application/json" }).
        to_return(body: new_pool_response)
    end

    it 'posts to the api' do
      new_pool = subject.mgmt.tm.ltm.pool.create(name: 'foobar')
      expect(WebMock).to have_requested(:post, "#{baseurl}/mgmt/tm/ltm/pool")
    end

    it 'returns the hash containing the data' do
      new_pool = subject.mgmt.tm.ltm.pool.create(name: 'foobar')

      expect(new_pool).to be_an_kind_of Hash
    end
  end

  describe 'adding a resource in a collection with add method' do
    before do
      stub_request(:post, "https://somehost/mgmt/tm/ltm/pool/foobar/members").
        with(
          body: "{\"name\":\"test_node:80\",\"address\":\"10.10.10.10\",\"description\":\"Adding a node\"}",
          headers: { 'Content-Type'=>'application/json' }).
        to_return(status: 200, body: new_member_response, headers: {})
    end
    it 'post to the api' do
      api_new_member = subject.mgmt.tm.ltm.pool.foobar.members.add(new_member)
      expect(WebMock).to have_requested(:post, "#{baseurl}/mgmt/tm/ltm/pool/foobar/members")
      expect(api_new_member).to be_an_kind_of Hash
    end
  end
  
  describe 'updating a sub-collection resource' do
    before do
      stub_request(:get, "https://somehost/mgmt/tm/ltm/pool/foobar/members/~Common~test_node:80").
        to_return(status: 200, body: new_member_response)

      stub_request(:patch, "https://somehost/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80").
        with(
          body: "{\"description\":\"Updated description\"}",
          headers: { 'Content-Type'=>'application/json' }).
        to_return(status: 200, body: updated_member)
    end
    it 'sends a patch request to the api' do
      subject.mgmt.tm.ltm.pool.foobar.members.load('~Common~test_node:80').update(description: 'Updated description')
      expect(WebMock).to have_requested(:patch, "#{baseurl}/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80")
    end
  end
  
  # TODO: Find a resource where PUT reset to default values instead of merging
  # describe 'replacing a resource sub-collection' do
  # end

  describe 'delete a resource' do
    before do
      stub_request(:get, "https://somehost/mgmt/tm/ltm/pool/foobar/members/~Common~test_node:80").
        to_return(status: 200, body: updated_member, headers: {})
      
      stub_request(:delete, "https://somehost/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80/").
        to_return(status: 200, body: "", headers: {})
    end
    it 'send a delete request to the api' do
      subject.mgmt.tm.ltm.pool.foobar.members.load('~Common~test_node:80').delete
      expect(WebMock).to have_requested(:delete, "#{baseurl}/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80/")
    end
  end

  def pool_collection
    '{"kind":"tm:ltm:pool:poolcollectionstate","selfLink":"https://localhost/mgmt/tm/ltm/pool?ver=11.5.1","items":[{"kind":"tm:ltm:pool:poolstate","name":"reallybasic","partition":"Common","fullPath":"/Common/reallybasic","generation":845,"selfLink":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic?ver=11.5.1","allowNat":"yes","allowSnat":"yes","ignorePersistedWeight":"disabled","ipTosToClient":"pass-through","ipTosToServer":"pass-through","linkQosToClient":"pass-through","linkQosToServer":"pass-through","loadBalancingMode":"round-robin","minActiveMembers":0,"minUpMembers":0,"minUpMembersAction":"failover","minUpMembersChecking":"disabled","queueDepthLimit":0,"queueOnConnectionLimit":"disabled","queueTimeLimit":0,"reselectTries":0,"slowRampTime":10,"membersReference":{"link":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic/members?ver=11.5.1","isSubcollection":true}},{"kind":"tm:ltm:pool:poolstate","name":"reallybasic2","partition":"Common","fullPath":"/Common/reallybasic2","generation":819,"selfLink":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic2?ver=11.5.1","allowNat":"yes","allowSnat":"yes","ignorePersistedWeight":"disabled","ipTosToClient":"pass-through","ipTosToServer":"pass-through","linkQosToClient":"pass-through","linkQosToServer":"pass-through","loadBalancingMode":"round-robin","minActiveMembers":0,"minUpMembers":0,"minUpMembersAction":"failover","minUpMembersChecking":"disabled","queueDepthLimit":0,"queueOnConnectionLimit":"disabled","queueTimeLimit":0,"reselectTries":0,"slowRampTime":10,"membersReference":{"link":"https://localhost/mgmt/tm/ltm/pool/~Common~reallybasic2/members?ver=11.5.1","isSubcollection":true}}]}'
  end

  def new_pool_response
    '{"kind":"tm:ltm:pool:poolstate","name":"foobar","fullPath":"foobar","generation":848,"selfLink":"https://localhost/mgmt/tm/ltm/pool/foobar?ver=11.5.1","allowNat":"yes","allowSnat":"yes","ignorePersistedWeight":"disabled","ipTosToClient":"pass-through","ipTosToServer":"pass-through","linkQosToClient":"pass-through","linkQosToServer":"pass-through","loadBalancingMode":"round-robin","minActiveMembers":0,"minUpMembers":0,"minUpMembersAction":"failover","minUpMembersChecking":"disabled","queueDepthLimit":0,"queueOnConnectionLimit":"disabled","queueTimeLimit":0,"reselectTries":0,"slowRampTime":10,"membersReference":{"link":"https://localhost/mgmt/tm/ltm/pool/~Common~foobar/members?ver=11.5.1","isSubcollection":true}}'
  end

  def new_member
    {name:'test_node:80', address:'10.10.10.10', description: 'Adding a node'}
  end

  def new_member_response
    '{"kind":"tm:ltm:pool:members:membersstate","name":"test_node:80","partition":"Common","fullPath":"/Common/test_node:80","generation":2589364,"selfLink":"https://localhost/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80?ver=13.1.3.4","address":"10.10.10.10%1","connectionLimit":0,"description":"Adding a node","dynamicRatio":1,"ephemeral":"false","fqdn":{"autopopulate":"disabled"},"inheritProfile":"enabled","logging":"disabled","monitor":"default","priorityGroup":0,"rateLimit":"disabled","ratio":1,"session":"user-enabled","state":"unchecked"}'
  end

  def updated_member
    '{"kind":"tm:ltm:pool:members:membersstate","name":"test_node:80","partition":"Common","fullPath":"/Common/test_node:80","generation":2589364,"selfLink":"https://localhost/mgmt/tm/ltm/pool/~Common~foobar/members/~Common~test_node:80?ver=13.1.3.4","address":"10.10.10.10%1","connectionLimit":0,"description":"Updated description","dynamicRatio":1,"ephemeral":"false","fqdn":{"autopopulate":"disabled"},"inheritProfile":"enabled","logging":"disabled","monitor":"default","priorityGroup":0,"rateLimit":"disabled","ratio":1,"session":"user-enabled","state":"unchecked"}'
  end
  
end
