require 'f5/icontrol/common/enum_item'

module F5
  module Icontrol
    module LocalLB
      module VirtualServer
        # https://devcentral.f5.com/wiki/iControl.LocalLB__VirtualServer__SourceAddressTranslationType.ashx
        # A list of source address translation types.
        module SourceAddressTranslationType
          # Translation type unknown (or unsupported by iControl).
          SRC_TRANS_UNKNOWN = EnumItem.new('SRC_TRANS_UNKNOWN', '0')

          # No translation is being used.
          SRC_TRANS_NONE = EnumItem.new('SRC_TRANS_NONE', '1')

          # The translation uses self IP addresses.
          SRC_TRANS_AUTOMAP = EnumItem.new('SRC_TRANS_AUTOMAP', '2')

          # The translation uses a SNAT pool of translation addresses.
          SRC_TRANS_SNATPOOL = EnumItem.new('SRC_TRANS_SNATPOOL', '3')

          # The translation uses an LSN pool of translation addresses.
          SRC_TRANS_LSNPOOL = EnumItem.new('SRC_TRANS_LSNPOOL', '4')
        end
      end
    end
  end
end
