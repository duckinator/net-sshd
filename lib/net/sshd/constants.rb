module Net
  module SSHD
    module MSG
      DISCONNECT      = 1
      IGNORE          = 2
      UNIMPL          = 3
      DEBUG           = 4
      REVICE_REQ      = 5 #?
      SERVICE_REQ     = 6
      # ...
      KEXINIT         = 20
      NEWKEYS         = 21
      # ...
      KEXECDH_INIT    = 30
      # ...
      AUTH_REQ        = 50
      AUTH_FAILURE    = 51
      AUTH_SUCCESS    = 52
      AUTH_BANNER     = 53
      # ...
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
