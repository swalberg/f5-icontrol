module F5
  module Icontrol
    module LocalLB
      # https://devcentral.f5.com/wiki/iControl.LocalLB__ProfileType.ashx
      # A list of profile types.
      module ProfileType
        # The TCP profile.
        PROFILE_TYPE_TCP = 0

        # The UDP profile.
        PROFILE_TYPE_UDP = 1

        # The FTP profile.
        PROFILE_TYPE_FTP = 2

        # The L4 translation profile.
        PROFILE_TYPE_FAST_L4 = 3

        # The HTTP profile.
        PROFILE_TYPE_HTTP = 4

        # The server-side SSL profile.
        PROFILE_TYPE_SERVER_SSL = 5

        # The client-side SSL profile.
        PROFILE_TYPE_CLIENT_SSL = 6

        # The authorization profile.
        PROFILE_TYPE_AUTH = 7

        # The persistence profile.
        PROFILE_TYPE_PERSISTENCE = 8

        # The connection pool profile.
        PROFILE_TYPE_CONNECTION_POOL = 9

        # The stream profile.
        PROFILE_TYPE_STREAM = 10

        # The XML profile.
        PROFILE_TYPE_XML = 11

        # The FastHTTP profile.
        PROFILE_TYPE_FAST_HTTP = 12

        # The IIOP profile.
        PROFILE_TYPE_IIOP = 13

        # The RTSP profile.
        PROFILE_TYPE_RTSP = 14

        # The STATISTICS profile.
        PROFILE_TYPE_STATISTICS = 15

        # The HTTP class profile.
        PROFILE_TYPE_HTTPCLASS = 16

        # The DNS profile.
        PROFILE_TYPE_DNS = 17

        # The SCTP profile.
        PROFILE_TYPE_SCTP = 18

        # A loosely-typed profile.
        PROFILE_TYPE_INSTANCE = 19

        # The SIP profile.
        PROFILE_TYPE_SIPP = 20

        # The HTTP Compression profile.
        PROFILE_TYPE_HTTPCOMPRESSION = 21

        # The Web Acceleration profile.
        PROFILE_TYPE_WEBACCELERATION = 22

        # Profile type is unknown (or is unsupported by iControl).
        PROFILE_TYPE_UNKNOWN = 23

        # The RADIUS profile.
        PROFILE_TYPE_RADIUS = 24

        # The Diameter profile.
        PROFILE_TYPE_DIAMETER = 25
      end
    end
  end
end
