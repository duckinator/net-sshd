require 'net/ssh/authentication/constants'
require 'net/ssh/transport/constants'

module Net
  module SSHD
    module Constants
      include ::Net::SSH::Authentication::Constants
      include ::Net::SSH::Transport::Constants
    end
  end
end
