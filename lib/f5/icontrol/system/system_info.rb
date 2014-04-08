require "savon"
module F5
  class Icontrol
    class System
      class SystemInfo < F5::Icontrol

        def get_version
          client("System.SystemInfo").call(:get_version).xpath('//m:get_versionResponse').inner_text.gsub /\n/, ""
        end

        private

      end
    end
  end
end
