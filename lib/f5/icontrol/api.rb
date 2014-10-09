module F5
  module Icontrol
    class API
      attr_accessor :api_path

      def initialize(api_path = nil)
        @username="a"
        @password="b"
        @hostname="xxx"
        @client_cache = {}
        @api_path = api_path
      end

      def method_missing(method, args = nil, &block)
        if terminal_node?
          if supported_method?(method)
            response_key = "#{method.to_s}_response".to_sym

            response = client.call(method) do
              if args
                message args
              end
            end

            response.to_hash[response_key][:return]

          else
            raise NameError, "#{@api_path} does not support #{method}"
          end
        else
          if supported_path? append_path(method)
            self.class.new append_path(method)
          else
            raise NameError, "#{append_path(method)} is not supported"
          end
        end
      end

      private

      def terminal_node?
        ::File.exists? "#{wsdl_path}/#{@api_path}.wsdl"
      end

      def supported_method?(method)
        client.operations.include?(method)
      end

      def supported_path?(path)
        ! Dir.glob("#{wsdl_path}/#{path}.*wsdl").empty?
      end

      def append_path(item)
        @api_path ? "#{@api_path}.#{item}" : item.to_s
      end

      def wsdl_path
        File.dirname(__FILE__).gsub /(f5-icontrol[^\/]*\/lib)\/.*/, "\\1/wsdl/"
      end

      def client
        api_namespace = @api_path.gsub /\./, '/'
        endpoint = '/iControl/iControlPortal.cgi'
        @client_cache[@api_path] ||=
          Savon.client(wsdl: "#{wsdl_path}#{@api_path}.wsdl",
                       endpoint: "https://#{F5::Icontrol.configuration.host}#{endpoint}",
                       ssl_verify_mode: :none,
                       basic_auth: [F5::Icontrol.configuration.username, F5::Icontrol.configuration.password],
                       #log: true,
                       #logger: Logger.new(STDOUT),
                       #pretty_print_xml: true,
                       #log_level: :debug,
                       namespace: "urn:iControl:#{api_namespace}",
                       convert_request_keys_to: :none
                      )
      end
    end
  end
end
