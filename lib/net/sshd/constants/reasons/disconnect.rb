# Reason codes from: http://www.iana.org/assignments/ssh-parameters/ssh-parameters.xml#ssh-parameters-2

module Net
  module SSHD
    module Constants
      module Disconnect
        HOST_NOT_ALLOWED_TO_CONNECT = 1
        PROTOCOL_ERROR        = 2
        KEY_EXCHANGE_FAILED   = 3
        RESERVED              = 4
        MAC_ERROR             = 5
        COMPRESSION_ERROR     = 6
        SERVICE_NOT_AVAILABLE = 7
        PROTOCOL_VERSION_NOT_SUPPORTED = 8
        HOST_KEY_NOT_VERIFIABLE = 9
        CONNECTION_LOST       = 10
        BY_APPLICATION        = 11
        TOO_MANY_CONNECTIONS  = 12
        AUTH_CANCELED_BY_USER = 13
        NO_MORE_AUTH_METHODS_AVAILABLE  = 14
        ILLEGAL_USER_NAME       = 15
      end
    end
  end
end
