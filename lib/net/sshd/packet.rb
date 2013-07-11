require 'net/ssh'

module Net
  module SSHD
    class Packet < Net::SSH::Packet
      attr_accessor :mac, :payload

      def initialize(buffer, old_mac, mac_length, deciph, macC, seqC)
        buffer = Net::SSH::Buffer.new.append(buffer)
        pkt_length = buffer.read_long
        pad_length = buffer.read_byte
        pay_length = pkt_length - pad_length

        @payload   = buffer.read(pay_length)
        original   = @payload

        padding    = buffer.read(pad_length)

        if deciph
          deciph.update(@payload)
          deciph.padding = padding

          deciph.decrypt

          @payload = deciph.final
        end

        @mac       = buffer.read(mac_length)

        if @payload != original
          puts "Encrypted: #{original.inspect}"
          puts "Decrypted: #{@payload.inspect}"
        end

        # FIXME: Check mac-related stuff.

        super(@payload)
      end

      def read_list
        str = read_string
        str.nil? ? [] : str.split(',')
      end
    end
  end
end
