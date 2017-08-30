require 'f5/icontrol/common/enum_item'

module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__AvailabilityStatus.ashx
      # A list of possible values for an object's availability status.
      module AvailabilityStatus
        # Error scenario.
        AVAILABILITY_STATUS_NONE = EnumItem.new('AVAILABILITY_STATUS_NONE', '0')

        # The object is available in some capacity.
        AVAILABILITY_STATUS_GREEN = EnumItem.new('AVAILABILITY_STATUS_GREEN', '1')

        # The object is not available at the current moment, but may become available again even without user intervention.
        AVAILABILITY_STATUS_YELLOW = EnumItem.new('AVAILABILITY_STATUS_YELLOW', '2')

        # The object is not available, and will require user intervention to make this object available again.
        AVAILABILITY_STATUS_RED = EnumItem.new('AVAILABILITY_STATUS_RED', '3')

        # The object's availability status is unknown.
        AVAILABILITY_STATUS_BLUE = EnumItem.new('AVAILABILITY_STATUS_BLUE', '4')

        # The object's is unlicensed.
        AVAILABILITY_STATUS_GRAY = EnumItem.new('AVAILABILITY_STATUS_GRAY', '5')
      end
    end
  end
end
