require 'spec_helper'

describe F5::Icontrol::API do
  before do
    F5::Icontrol.configure do
    end
  end

  describe '#initialize' do
  end

  describe 'a non terminal object' do
    it "returns another version of itself" do
      expect(subject.LocalLB.class).to eq described_class
    end

    it "stores the path" do
      expect(subject.LocalLB.api_path).to eq "LocalLB"
    end
  end

  describe 'a terminal object' do
    it "returns another version of itself" do
      expect(subject.LocalLB.Pool.class).to eq described_class
    end

    it "stores the path" do
      expect(subject.LocalLB.Pool.api_path).to eq "LocalLB.Pool"
    end
  end

  describe 'a terminal object with a method' do
    let(:client) { double('SavonClient', operations: [ :get_list ]) }

    before do
      expect(Savon).to receive(:client).and_return(client)
      expect(client).to receive(:call).with(:get_list).and_return({get_list_response: { return: "foo" }})
    end

    it "calls the method" do
      subject.LocalLB.Pool.get_list
    end
  end

  describe 'a non existent method' do
    it "raises on non terminal method" do
      expect { subject.foo }.to raise_error(NameError)
    end

    it "raises on terminal method" do
      expect { subject.LocalLB.Pool.foo }.to raise_error(NameError)
    end
  end
end
