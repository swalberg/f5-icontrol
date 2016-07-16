require 'rest-client'
require 'json'

module F5
  module Icontrol
    class RAPI
      def initialize(method_chain = nil, **args)
        @method_chain = method_chain || ''
        @args = args
      end

      def load
        get_collection
      end

      def get_collection
        response = RestClient::Resource.new(url,
                                            verify_ssl: OpenSSL::SSL::VERIFY_NONE
                                           ).get
        objects = JSON.parse response.body

        objects['items'].map { |r| Resource.new r, @args }
      end

      def method_missing(method, *args, &block)
        F5::Icontrol::RAPI.new("#{@method_chain}#{method}/", @args)
      end

      def each
        get_collection.each
      end

      private
      def url
        method_chain = @method_chain.gsub /_/, '-'
        "https://#{@args[:username]}:#{@args[:password]}@#{@args[:host]}/#{method_chain}"
      end
    end
  end
end
