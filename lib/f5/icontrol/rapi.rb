require 'rest-client'
require 'json'

module F5
  module Icontrol
    class RAPI

      @@credentials = {}

      def initialize(method_chain = nil, **args)
        @method_chain = method_chain
        @args = args
      end

      def load
        get_collection
      end

      def get_collection
        #puts "calling #{@method_chain}"
        response = RestClient::Resource.new("https://#{@args[:username]}:#{@args[:password]}@#{@args[:host]}/#{@method_chain}",
                                            verify_ssl: OpenSSL::SSL::VERIFY_NONE
                                           ).get
        #puts response.body
        objects = JSON.parse response.body

        objects['items'].map { |r| Resource.new r, @args }
      end

      def method_missing(method, args = nil, &block)
        F5::Icontrol::RAPI.new("#{@method_chain}#{method}/", @args)
      end
    end
  end
end
