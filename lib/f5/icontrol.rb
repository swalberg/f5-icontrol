require "f5/icontrol/version"
require "f5/icontrol/system/system_info"
require "openssl"
require "savon"

module F5
  class Icontrol
    def initialize(host, username, password)
      @hostname = host
      @username = username
      @password = password
      @client_cache = {}
    end

    private

    def wsdl_path
      File.dirname(__FILE__).gsub /f5-icontrol\/lib\/.*/, "f5-icontrol/lib/wsdl/"
    end



    def client(api_group)
      api_namespace = api_group.gsub /\./, '/'
      endpoint = '/iControl/iControlPortal.cgi'
      @client_cache[api_group] ||=
        Savon.client(wsdl: "#{wsdl_path}#{api_group}.wsdl",
                     endpoint: "https://#{@hostname}#{endpoint}",
                     ssl_verify_mode: :none,
                     basic_auth: [@username, @password],
                     #log: true,
                     #logger: Logger.new(STDOUT),
                     #pretty_print_xml: true,
                     #log_level: :debug,
                     namespace: "urn:iControl:#{api_namespace}"
                    )
    end
  end
end
