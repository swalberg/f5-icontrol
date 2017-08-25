module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__EnabledStatus.ashx
      # A list of possible values for enabled status.
      module EnabledStatus
        # Error scenario.
        ENABLED_STATUS_NONE = 0

        #	The object is active when in Green
        # availability status. It may or may
        # not be active when in Blue
        # availability status.
        ENABLED_STATUS_ENABLED = 1

        #	The object is inactive regardless
        # of availability status.
        ENABLED_STATUS_DISABLED	= 2

        #	The object is inactive regardless of
        # availability status because its parent
        # has been disabled, but the object
        # itself is still enabled.
        ENABLED_STATUS_DISABLED_BY_PARENT	= 3
      end
    end
  end
end
