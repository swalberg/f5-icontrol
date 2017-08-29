module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__ProfileContextType.ashx
      # A list of profile context types.
      module ProfileContextType
        # Profile applies to both client and server sides.
        PROFILE_CONTEXT_TYPE_ALL = 0

        # Profile applies to the client side only.
        PROFILE_CONTEXT_TYPE_CLIENT = 1

        # Profile applies to the server side only.
        PROFILE_CONTEXT_TYPE_SERVER = 2
      end
    end
  end
end
