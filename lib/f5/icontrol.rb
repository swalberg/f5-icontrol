require "f5/icontrol/version"
require "f5/icontrol/rapi"
require "f5/icontrol/api"
require 'f5/icontrol/common/enabled_state'
require 'f5/icontrol/common/enum_item'
require 'f5/icontrol/locallb/virtual_server/source_address_translation'
require 'f5/icontrol/locallb/availability_status'
require 'f5/icontrol/locallb/client_ssl_certificate_mode'
require 'f5/icontrol/locallb/enabled_status'
require 'f5/icontrol/locallb/profile_context_type'
require 'f5/icontrol/locallb/profile_type'
require 'f5/icontrol/locallb/server_ssl_certificate_mode'
require 'f5/icontrol/rapi/resource'
require "openssl"
require "savon"

module F5
  module Icontrol
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield configuration
    end

    class Configuration
      attr_accessor :host, :username, :password

      def initialize
        @host = "set_me_in_configure_block"
        @username = ""
        @password = ""
      end
    end

  end
end
