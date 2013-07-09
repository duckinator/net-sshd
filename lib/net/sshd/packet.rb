require 'net/ssh'

module Net
  module SSHD
    class Packet < Net::SSH::Packet
      attr_accessor :mac, :payload

      def initialize(buffer, mac_length)
        buffer = Net::SSH::Buffer.new.append(buffer)
        pkt_length = buffer.read_long
        pad_length = buffer.read_byte
        pay_length = pkt_length - pad_length
        @payload   = buffer.read(pay_length)
        padding    = buffer.read(pad_length)
        @mac       = buffer.read(mac_length)

        super(payload)
      end

      def read_list
        str = read_string
        str.nil? ? [] : str.split(',')
      end
    end
  end
end
