require 'f5/icontrol/common/enum_item'

module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__ClientSSLCertificateMode.ashx
      # A list of client-side SSL certificate modes.
      module ClientSSLCertificateMode
        # The client certificate is requested.
        CLIENTSSL_CERTIFICATE_MODE_REQUEST = EnumItem.new('CLIENTSSL_CERTIFICATE_MODE_REQUEST', '0')

        # The client certificate is required.
        CLIENTSSL_CERTIFICATE_MODE_REQUIRE = EnumItem.new('CLIENTSSL_CERTIFICATE_MODE_REQUIRE', '1')

        # The client certificate is ignored.
        CLIENTSSL_CERTIFICATE_MODE_IGNORE = EnumItem.new('CLIENTSSL_CERTIFICATE_MODE_IGNORE', '2')

        # The client certificate processing is auto. As of version 11.0.0, certificate mode AUTO is equivalent to IGNORE.
        CLIENTSSL_CERTIFICATE_MODE_AUTO = EnumItem.new('CLIENTSSL_CERTIFICATE_MODE_AUTO', '3')
      end
    end
  end
end
