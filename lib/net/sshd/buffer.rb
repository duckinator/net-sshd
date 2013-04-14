module Net
  module SSHD
    class Buffer < String
      def initialize(length = nil, fill = "\x00")
        @buffer_length = length
        @index = 0
        if length.nil?
          @buffer_length = fill.length
          super(fill)
        else
          super(fill * length)
        end
      end

      # READ

      def readBool(index)
        readUInt8(index) > 0 
      end

      def readString(index, length)
        self[index, length].unpack("B#{length}").first
      end

      def readUInt8(index)
        self[index..-1].unpack('C').first
      end

      def readUInt32BE(index)
        self[index..-1].unpack('L>').first
      end

      def readUInt64BE(index)
        self[index..-1].unpack('Q>').first
      end

      # WRITE


      def writeBool(x, index)
        writeUInt8(index, x ? 1 : 0)
      end

      def writeString(str, index)
        self[index, str.length] = str
        str
      end

      # Native endian, signed

      def writeInt8(i, index)
        tmp = [i].pack('c')
        self[index, tmp.length] = tmp
      end

      def writeInt16(i, index)
        tmp = [i].pack('s')
        self[index, tmp.length] = tmp
      end

      def writeInt32(i, index)
        tmp = [i].pack('l')
        self[index, tmp.length] = tmp
      end

      def writeInt64(i, index)
        tmp = [i].pack('q')
        self[index, tmp.length] = tmp
      end

      # Native endian, unsigned

      def writeUInt8(i, index)
        tmp = [i].pack('C')
        self[index, tmp.length] = tmp
      end

      def writeUInt16(i, index)
        tmp = [i].pack('S')
        self[index, tmp.length] = tmp
      end

      def writeUInt32(i, index)
        tmp = [i].pack('L')
        self[index, tmp.length] = tmp
      end

      def writeUInt64(i, index)
        tmp = [i].pack('Q')
        self[index, tmp.length] = tmp
      end

      # Little endian, signed

      def writeInt16LE(i, index)
        tmp = [i].pack('s<')
        self[index, tmp.length] = tmp
      end

      def writeInt32LE(i, index)
        tmp = [i].pack('l<')
        self[index, tmp.length] = tmp
      end

      def writeInt64LE(i, index)
        tmp = [i].pack('q<')
        self[index, tmp.length] = tmp
      end

      # Little endian, unsigned

      def writeUInt16LE(i, index)
        tmp = [i].pack('S<')
        self[index, tmp.length] = tmp
      end

      def writeUInt32LE(i, index)
        tmp = [i].pack('L<')
        self[index, tmp.length] = tmp
      end

      def writeUInt64LE(i, index)
        tmp = [i].pack('Q<')
        self[index, tmp.length] = tmp
      end

      # Big endian, signed

      def writeInt16BE(i, index)
        tmp = [i].pack('s>')
        self[index, tmp.length] = tmp
      end

      def writeInt32BE(i, index)
        tmp = [i].pack('l>')
        self[index, tmp.length] = tmp
      end

      def writeInt64BE(i, index)
        tmp = [i].pack('q>')
        self[index, tmp.length] = tmp
      end

      # Big endian, unsigned

      def writeUInt16BE(i, index)
        tmp = [i].pack('S>')
        self[index, tmp.length] = tmp
      end

      def writeUInt32BE(i, index)
p index
        tmp = [i].pack('L>')
p tmp
        self[index, tmp.length] = tmp
      end

      def writeUInt64BE(i, index)
        tmp = [i].pack('Q>')
        self[index, tmp.length] = tmp
      end

      def writeUInt16NE(i, index)
        tmp = [i].pack('n')
        self[index, tmp.length] = tmp
      end

      def writeUInt32NE(i, index)
        tmp = [i].pack('N')
        self[index, tmp.length] = tmp
      end
    end
  end
end
