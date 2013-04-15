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

      # Dupes! These
      KEXDH_INIT      = 30
      KEXDH_REPLY     = 31
      KEXECDH_INIT    = 30
      KEXECDH_REPLY   = 31

      # ...
      KEX_DH_GEX_REQ  = 34
      # ...

      # Authentication
      AUTH_REQ        = 50
      AUTH_FAILURE    = 51
      AUTH_SUCCESS    = 52
      AUTH_BANNER     = 53
      # ...
      AUTH_PASSWD_CHANGEREQ = 60
      AUTH_PK_OK      = 60
      # ...
      USERAUTH_METHOD_RANGE = 60..79

      GLOBAL_REQ      = 80
      REQ_SUCCESS     = 81
      REQ_FAILURE     = 82
      # ...
      CHAN_OPEN       = 90
      CHAN_OPEN_CONF  = 91
      CHAN_OPEN_FAIL  = 92
      CHAN_WINDOW_ADJ = 93
      CHAN_DATA       = 94
      CHAN_EXT_DATA   = 95
      CHAN_EOF        = 96
      CHAN_CLOSE      = 97
      CHAN_REQUEST    = 98
      CHAN_SUCCESS    = 99
      CHAN_FAIL       = 100

    end
  end
end
