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
    end
  end
end
