require "savon"
module F5
  class Icontrol
    class System
      class SystemInfo < F5::Icontrol

        def get_version
          client("System.SystemInfo").call(:get_version).to_hash[:get_version_response][:return]
        end

        def get_uptime
          client("System.SystemInfo").call(:get_uptime).to_hash[:get_uptime_response][:return]
        end

        private

      end
    end
  end
end
