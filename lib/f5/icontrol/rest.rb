require 'rest-client'
require 'json'
require 'f5/icontrol/rest/errors'

module F5
  module Icontrol
    class REST

      include Enumerable

      def initialize(method_chain = nil, **args)
        @method_chain = method_chain || ''
        @args = args
      end

      def load(resource = nil)
        begin
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
        rescue RestClient::Exception => e
          raise_error(e)
        end 
      end

      def get_collection
        begin
          response = RestClient::Request.execute(method: :get,
                                                url: "#{url}/",
                                                user: @args[:username],
                                                password: @args[:password],
                                                verify_ssl: OpenSSL::SSL::VERIFY_NONE
                                            )
          objects = JSON.parse response.body

          objects['items'].map { |r| Resource.new r, @args }
        rescue RestClient::Exception => e
          raise_error(e)
        end
      end

      def create(options = {})
        begin
          response = RestClient::Request.execute(method: :post,
                                                url: url,
                                                user: @args[:username],
                                                password: @args[:password],
                                                verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                                payload: options.to_json,
                                                headers: { "content-type" => "application/json" }
                                                )
          JSON.parse response.body
        rescue RestClient::Exception => e
          raise_error(e)
        end
      end

      alias add create

      def update(options = {})
        raise F5::Icontrol::REST::Error.new("Update of #{resource} called without changes") if options.nil? || options.empty?
        begin
          response = RestClient::Request.execute(method: :patch,
                                                url: url,
                                                user: @args[:username],
                                                password: @args[:password],
                                                verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                                payload: options.to_json,
                                                headers: { "content-type" => "application/json" }
                                                )
          JSON.parse response.body
        rescue RestClient::Exception => e
          raise_error(e)
        end
      end

      def replace(options = {})
        raise F5::Icontrol::REST::Error.new("Replacement of #{resource} called without definition of the new parameters") if options.nil? || options.empty?
        begin
          response = RestClient::Request.execute(method: :put,
                                                url: url,
                                                user: @args[:username],
                                                password: @args[:password],
                                                verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                                payload: options.to_json,
                                                headers: { "content-type" => "application/json" }
                                                )
          JSON.parse response.body
        rescue RestClient::Exception => e
          raise_error(e)
        end
      end

      def delete(resource = nil)
        tail = resource.nil? ? '' : "/#{resource}"
        begin
          RestClient::Request.execute(method: :delete,
                                                url: "#{url}/#{tail}",
                                                user: @args[:username],
                                                password: @args[:password],
                                                verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                                headers: { "content-type" => "application/json" }
                                                )
        rescue RestClient::Exception => e
          raise_error(e)
        end
      end

      def method_missing(method, *args, &block)
        new_method_chain = @method_chain == '/' ? '': "#{@method_chain}/"
        F5::Icontrol::REST.new("#{new_method_chain}#{method}", @args)
      end

      def each(&block)
        get_collection.each &block
      end

      private
      def url
        m_chain = @method_chain
        non_name_matches=m_chain.scan %r{/[^~/]+_[^/]+}
        non_name_matches.each do |m|
          rep = m.tr '_', '-'
          m_chain.sub! m, rep
        end
        m_chain.gsub! %r{^/}, ''
        "https://#{@args[:host]}/#{m_chain}"
      end
    end

    # Provide a backward compatibility on class name
    RAPI = REST

  end
end
