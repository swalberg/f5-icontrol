require "savon"
module F5
  class Icontrol
    class System
      class SystemInfo < F5::Icontrol

        def get_version
          client.call(:get_version).xpath('//m:get_versionResponse').inner_text.gsub /\n/, ""
        end

        private

        def client
          wsdl_path = File.dirname(__FILE__) + "/../../../wsdl/System.SystemInfo.wsdl"
          @endpoint = '/iControl/iControlPortal.cgi'
          Savon.client(wsdl: wsdl_path,
                       endpoint: "https://#{@hostname}#{@endpoint}",
                       ssl_verify_mode: :none,
                       basic_auth: [@username, @password],
                       #log: true,
                       #logger: Logger.new(STDOUT),
                       #pretty_print_xml: true,
                       #log_level: :debug,
                       namespace: "urn:iControl:System/SystemInfo"
                      )
        end
      end
    end
  end
end
