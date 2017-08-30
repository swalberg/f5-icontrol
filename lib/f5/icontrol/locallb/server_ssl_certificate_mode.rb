require 'f5/icontrol/common/enum_item'

module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__ServerSSLCertificateMode.ashx
      # A list of server-side SSL certificate modes.
      module ServerSSLCertificateMode
        # The certificate is required.
        SERVERSSL_CERTIFICATE_MODE_REQUIRE = EnumItem.new('SERVERSSL_CERTIFICATE_MODE_REQUIRE', '0')

        # The certificate is ignored.
        SERVERSSL_CERTIFICATE_MODE_IGNORE = EnumItem.new('SERVERSSL_CERTIFICATE_MODE_IGNORE', '1')
      end
    end
  end
end
