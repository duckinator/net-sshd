# Message numbers from: http://www.iana.org/assignments/ssh-parameters/ssh-parameters.xml#ssh-parameters-1

module Net
  module SSHD
    module Constants
      module MSG
        # Transport layer generic messages
        DISCONNECT      = 1
        IGNORE          = 2
        UNIMPLEMENTED   = 3
        DEBUG           = 4
        SERVICE_REQUEST = 5
        SERVICE_ACCEPT  = 6

        # 7-19 unassigned (transport layer generic)

        # Algorithm negotiation messages
        KEXINIT         = 20
        NEWKEYS         = 21

        # 20-29 unassigned (algorithm negotiation)

        # 30-49 are key exchange method specific

          # Diffie-Hellman key exchange
          KEX_DH_INIT     = 30
          KEX_DH_REPLY    = 31

          # Diffie-Hellman Group Exchange (RFC: http://www.ietf.org/rfc/rfc4419.txt)
          KEX_DH_GEX_REQUEST_OLD = 30
          KEX_DH_GEX_REQUEST  = 34
          KEX_DH_GEX_GROUP    = 31
          KEX_DH_GEX_INIT     = 32
          KEX_DH_GEX_REPLY    = 33
          # I don't believe there is a 34-39 defined for DH Group Exchange

          # ? key exchange  # TODO: find the name of this key exchange
          KEXECDH_INIT    = 30
          KEXECDH_REPLY   = 31
          # TODO: Find 32-39 for this key exchange method

        # Authentication
        USERAUTH_REQUEST   = 50
        USERAUTH_FAILURE   = 51
        USERAUTH_SUCCESS   = 52
        USERAUTH_BANNER    = 53

        # 54-59 unassigned (user authentication generic)

        # Okay, why are there three #60s?
          USERAUTH_PASSWD_CHANGEREQ = 60

          USERAUTH_PK_OK   = 60

          USERAUTH_INFO_REQUEST  = 60
          USERAUTH_INFO_RESPONSE = 61

        # 62-79 reserved (user authentication method specific)

        GLOBAL_REQUEST     = 80
        REQUEST_SUCCESS    = 81
        REQUEST_FAILURE    = 82

        # 83-89 unassigned (connection protocol generic)

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

        # 101-127 unassigned (channel related messages)

        # 128-191 reserved (for client protocols)

        # 192-255 reserved for private use (local extensions)
      end
    end
  end
end
