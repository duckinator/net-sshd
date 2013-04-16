# A lot of this is based off stuff in net/ssh:
# - https://github.com/net-ssh/net-ssh/blob/master/lib/net/ssh/transport/constants.rb
# - https://github.com/net-ssh/net-ssh/blob/master/lib/net/ssh/authentication/constants.rb

module Net
  module SSHD
    module Constants

      # Transport layer generic messages
      DISCONNECT      = 1
      IGNORE          = 2
      UNIMPLEMENTED   = 3
      DEBUG           = 4
      SERVICE_REQUEST = 5
      SERVICE_ACCEPT  = 6
      # ...


      # Algorithm negotiation messages
      KEXINIT         = 20
      NEWKEYS         = 21

      # ...

      # Dupes!
      KEX_DH_INIT     = 30
      KEX_DH_REPLY    = 31
      KEXECDH_INIT    = 30
      KEXECDH_REPLY   = 31

      KEX_DH_GEX_INIT = 32
      KEX__UNKNOWN_33 = 33 # TODO: Find the name of this.
      KEX_DH_GEX_REQ  = 34
      # ...

      # Authentication
      USERAUTH_REQUEST   = 50
      USERAUTH_FAILURE   = 51
      USERAUTH_SUCCESS   = 52
      USERAUTH_BANNER    = 53
      # ...
      USERAUTH_PASSWD_CHANGEREQ = 60
      USERAUTH_PK_OK     = 60
      # ...
      USERAUTH_METHOD_RANGE = 60..79

      GLOBAL_REQUEST     = 80
      REQUEST_SUCCESS    = 81
      REQUEST_FAILURE    = 82
      # ...
      CHANNEL_OPEN       = 90
      CHANNEL_OPEN_CONF  = 91
      CHANNEL_OPEN_FAIL  = 92
      CHANNEL_WINDOW_ADJ = 93
      CHANNEL_DATA       = 94
      CHANNEL_EXT_DATA   = 95
      CHANNEL_EOF        = 96
      CHANNEL_CLOSE      = 97
      CHANNEL_REQUEST    = 98
      CHANNEL_SUCCESS    = 99
      CHANNEL_FAIL       = 100

    end
  end
end
