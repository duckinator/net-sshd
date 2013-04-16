module Net
  module SSHD
    module Constants
      module ChannelConnectionFailure
        ADMINISTRATIVELY_PROHIBITED = 1
        CONNECT_FAILED        = 2
        UNKNOWN_CHANNEL_TYPE  = 3
        RESOURCE_SHORTAGE     = 4

        # 0x00000005-0xFDFFFFFF unassigned
        # 0xFE000000-0xFFFFFFFF reserved for private use
      end
    end
  end
end
