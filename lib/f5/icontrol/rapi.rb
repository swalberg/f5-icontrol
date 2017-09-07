require 'rest-client'
require 'json'

module F5
  module Icontrol
    class RAPI
      include Enumerable

      def initialize(method_chain = nil, **args)
        @method_chain = method_chain || ''
        @args = args
      end

      def load(resource = nil)
        tail = resource.nil? ? '' : "/#{resource}"
        response = RestClient::Request.execute(method: :get,
                                               url: "#{url}#{tail}",
                                               user: @args[:username],
                                               password: @args[:password],
                                               verify_ssl: OpenSSL::SSL::VERIFY_NONE
                                           )
        object = JSON.parse response.body

        if object.has_key? 'items'
          object['items'].map { |r| Resource.new r, @args }
        else
          Resource.new object, @args
        end
      end

      def get_collection
        response = RestClient::Request.execute(method: :get,
                                               url: "#{url}/",
                                               user: @args[:username],
                                               password: @args[:password],
                                               verify_ssl: OpenSSL::SSL::VERIFY_NONE
                                           )
        objects = JSON.parse response.body

        objects['items'].map { |r| Resource.new r, @args }
      end

      def create(options = {})
        response = RestClient::Request.execute(method: :post,
                                               url: url,
                                               user: @args[:username],
                                               password: @args[:password],
                                               verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                               payload: options.to_json,
                                               headers: { "content-type" => "application/json" }
                                              )
        JSON.parse response.body
      end

      def method_missing(method, *args, &block)
        new_method_chain = @method_chain == '/' ? '': "#{@method_chain}/"
        F5::Icontrol::RAPI.new("#{new_method_chain}#{method}", @args)
      end

      def each(&block)
        get_collection.each &block
      end

      private
      def url
        method_chain = @method_chain.gsub /_/, '-'
        method_chain.gsub! %r{^/}, ''
        "https://#{@args[:host]}/#{method_chain}"
      end
    end
  end
end
