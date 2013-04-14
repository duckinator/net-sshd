require 'net/ssh'

module Net
  module SSHD
    class Packet < Net::SSH::Buffer
      attr_accessor :type, :mac

      def initialize(buffer, mac_length)
        super()
        buffer = Net::SSH::Buffer.new.append(buffer)
        pkt_length = buffer.read_long
        pad_length = buffer.read_byte
        pay_length = pkt_length - pad_length
        payload    = buffer.read(pay_length)
        padding    = buffer.read(pad_length)
        @mac       = buffer.read(mac_length)

        append(payload)

        @type = read_byte
      end

      def read_list
        str = read_string
        str.nil? ? [] : str.split(',')
      end
    end
  end
end
