require 'spec_helper'
require 'f5/cli/application'

describe F5::Cli::Pool do
  before do
    allow(subject).to receive(:client).and_return(client)
  end

  let(:client) { double }

  context "list" do
    let(:output) { capture(:stdout) { subject.list } }

    context "no pools" do
      it "indicates there are no pools" do
        allow(client).to receive_message_chain("LocalLB", "Pool", "get_list") { { item: nil } }
        expect(output).to include("No pools found")
      end
    end

    context "one pool" do
      it "lists the pools" do
        allow(client).to receive_message_chain("LocalLB", "Pool", "get_list") { { item: "/Common/foobar" } }
        expect(output).to eq("/Common/foobar\n")
      end
    end

    context "two pools" do
      it "lists the pools" do
        allow(client).to receive_message_chain("LocalLB", "Pool", "get_list") { { item: [ "/Common/one", "/Common/two" ] } }
        expect(output).to eq("/Common/one\n/Common/two\n")
      end
    end
  end
end
