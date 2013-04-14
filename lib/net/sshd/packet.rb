module Net
  module SSHD
    class Packet
      attr_accessor :payload, :idx

      def initialize(buffer, mac_length)
        buffer = Buffer.new(nil, buffer)
        pkt_length = buffer.readUInt32BE(0)
        pad_length = buffer.readUInt8(4)
        pay_length = pkt_length - pad_length
        mac_idx    = 4 + pkt_length

        @payload = buffer.slice(5...(4 + pay_length))
        mac      = buffer.slice(mac_idx...(mac_idx + mac_length))

        @idx = 1
      end

      def getType
        @payload.unpack('C').first
      end

      def readBool
        readUInt8 > 0
      end

      def readUInt8
        tmp = @payload[@idx..-1].unpack('C')
        @idx += 1
        tmp.first
      end

      def readUInt32
        tmp = @payload[@idx..-1].unpack('L>')
        @idx += 4
        tmp.first
      end

      def readBuffer(len = nil)
        len = readUInt32 unless len
        @payload.slice(@idx...(@idx += len))
      end

      # readString(len) to readBuffer(len), because our buffers are strings.
      alias :readString :readBuffer

      def readList
        str = readString
        str.nil? ? [] : str.split(',')
      end
    end
  end
end
