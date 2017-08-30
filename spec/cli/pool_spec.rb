require 'spec_helper'
require 'f5/cli/application'

describe F5::Cli::Pool do
  before do
    allow(subject).to receive(:client).and_return(client)
  end

  let(:client) { double }

  context "setconnections" do
    let(:pool) { double("Pool") }
    let(:out) { 'yup' }

    before do
      allow(pool).to receive(:get_member_v2).and_return(members)
      allow(client).to receive_message_chain("LocalLB", "Pool") { pool }
      subject.options = { limit: 42 }
    end

    context "one member" do
      let(:expected) {
        {
          pool_names: { item: [ 'mypool' ] },
          members: { item: [ [ { address: '/Common/node1', port: '80' } ] ] },
          limits: {  item: [ [ 42 ] ] }
        }
      }
      let(:members) {
        {:item=>{:item=>{:address=>"/Common/node1", :port=>"80"}, :"@a:array_type"=>"iControl:Common.AddressPort[1]"}, :"@s:type"=>"A:Array", :"@a:array_type"=>"iControl:Common.AddressPort[][1]"}
      }

      it "calls the API to set the member" do
        expect(pool).to receive(:set_member_connection_limit).with(expected).and_return(out)

        subject.setconnections('mypool', 'node1')
      end
    end

    context "two members" do
      let(:expected) {
        {
          pool_names: { item: [ 'mypool' ] },
          members: { item: [ [ { address: '/Common/node1', port: '80' }, { address: '/Common/node2', port: '80' } ] ] },
          limits: {  item: [[ 42, 42 ]] }
        }
      }

      let(:members) {
        {:item=>{:item=>[{:address=>"/Common/node1", :port=>"80"}, {:address=>"/Common/node2", :port=>"80"}], :"@a:array_type"=>"iControl:Common.AddressPort[2]"}, :"@s:type"=>"A:Array", :"@a:array_type"=>"iControl:Common.AddressPort[][1]"}
      }

      it "calls the API to set the members" do
        expect(pool).to receive(:set_member_connection_limit).with(expected).and_return(out)

        subject.setconnections('mypool', 'node1', 'node2')
      end
    end
  end

  context "setratio" do
    let(:pool) { double("Pool") }
    let(:out) { 'yup' }

    before do
      allow(pool).to receive(:get_member_v2).and_return(members)
      allow(client).to receive_message_chain("LocalLB", "Pool") { pool }
      subject.options = { ratio: 42 }
    end

    context "one member" do
      let(:expected) {
        {
          pool_names: { item: [ 'mypool' ] },
          members: { item: [ [ { address: '/Common/node1', port: '80' } ] ] },
          ratios: {  item: [ [ 42 ] ] }
        }
      }
      let(:members) {
        {:item=>{:item=>{:address=>"/Common/node1", :port=>"80"}, :"@a:array_type"=>"iControl:Common.AddressPort[1]"}, :"@s:type"=>"A:Array", :"@a:array_type"=>"iControl:Common.AddressPort[][1]"}
      }

      it "calls the API to set the member" do
        expect(pool).to receive(:set_member_ratio).with(expected).and_return(out)

        subject.setratio('mypool', 'node1')
      end
    end

    context "two members" do
      let(:expected) {
        {
          pool_names: { item: [ 'mypool' ] },
          members: { item: [ [ { address: '/Common/node1', port: '80' }, { address: '/Common/node2', port: '80' } ] ] },
          ratios: {  item: [[ 42, 42 ]] }
        }
      }

      let(:members) {
        {:item=>{:item=>[{:address=>"/Common/node1", :port=>"80"}, {:address=>"/Common/node2", :port=>"80"}], :"@a:array_type"=>"iControl:Common.AddressPort[2]"}, :"@s:type"=>"A:Array", :"@a:array_type"=>"iControl:Common.AddressPort[][1]"}
      }

      it "calls the API to set the members" do
        expect(pool).to receive(:set_member_ratio).with(expected).and_return(out)

        subject.setratio('mypool', 'node1', 'node2')
      end
    end
  end

  context "list" do
    let(:output) { capture(:stdout) { subject.list } }

    before do
      allow(client).to receive_message_chain("LocalLB", "Pool", "get_list") { api_result }
    end

    context "no pools" do
      let(:api_result) { { item: nil } }
      it "indicates there are no pools" do
        expect(output).to include("No pools found")
      end
    end

    context "one pool" do
      let(:api_result) { { item: "/Common/foobar" } }
      it "lists the pools" do
        expect(output).to eq("/Common/foobar\n")
      end
    end

    context "two pools" do
      let(:api_result) { { item: [ "/Common/one", "/Common/two" ] } }
      it "lists the pools" do
        expect(output).to eq("/Common/one\n/Common/two\n")
      end
    end
  end
end
