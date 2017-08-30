require 'f5/icontrol/common/enum_item'

module F5
  module Icontrol
    module Common
      module EnabledState
        STATE_DISABLED = EnumItem.new('STATE_DISABLED', 0)
        STATE_ENABLED  = EnumItem.new('STATE_ENABLED', 1)
      end
    end
  end
end
