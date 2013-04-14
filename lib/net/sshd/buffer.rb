module Net
  module SSHD
    class Buffer < String
      def initialize(length = nil, _fill = nil)
        fill = _fill || "\x00"
        @buffer_length = length
        @index = 0
        if length.nil? && !_fill.nil?
          @buffer_length = fill.length
          super(fill)
        elsif length.nil?
          @buffer_length = :dynamic
          super()
        else
          super(fill * length)
        end
      end

      def pack(*args)
        arr =
          if args[0].is_a?(Array)
            args[0]
          else
            args
          end

        arr.each do |x|
          key = x.keys[0].to_s
          val = x[x.keys[0]]
          case key
          when 'byte'
            key = 'uint8'
          when 'bool'
            key = 'uint8'
            val = val ? 1 : 0
          when 'name_list'
            key = 'string'
            val = val.join(',')
          end

          meth = "write" + key.capitalize.gsub('int', 'Int').gsub('le', 'LE').gsub('be', 'BE').gsub('ne', 'NE')
          puts "#{meth}(#{val.inspect})"
          send(meth, val)
        end

        self
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


      def writeBool(x, index = self.length)
        writeUInt8(index, x ? 1 : 0)
      end

      def writeRaw(str, index = self.length)
        self[index, str.length] = str
        str
      end

      def writeString(str, index = self.length)
        len_str = writeUInt32BE(str.length, index)
        writeRaw(str, index + len_str.length)
      end

      # Native endian, signed

      def writeInt8(i, index = self.length)
        tmp = [i].pack('c')
        self[index, tmp.length] = tmp
      end

      def writeInt16(i, index = self.length)
        tmp = [i].pack('s')
        self[index, tmp.length] = tmp
      end

      def writeInt32(i, index = self.length)
        tmp = [i].pack('l')
        self[index, tmp.length] = tmp
      end

      def writeInt64(i, index = self.length)
        tmp = [i].pack('q')
        self[index, tmp.length] = tmp
      end

      # Native endian, unsigned

      def writeUInt8(i, index = self.length)
        tmp = [i].pack('C')
        self[index, tmp.length] = tmp
      end

      def writeUInt16(i, index = self.length)
        tmp = [i].pack('S')
        self[index, tmp.length] = tmp
      end

      def writeUInt32(i, index = self.length)
        tmp = [i].pack('L')
        self[index, tmp.length] = tmp
      end

      def writeUInt64(i, index = self.length)
        tmp = [i].pack('Q')
        self[index, tmp.length] = tmp
      end

      # Little endian, signed

      def writeInt16LE(i, index = self.length)
        tmp = [i].pack('s<')
        self[index, tmp.length] = tmp
      end

      def writeInt32LE(i, index = self.length)
        tmp = [i].pack('l<')
        self[index, tmp.length] = tmp
      end

      def writeInt64LE(i, index = self.length)
        tmp = [i].pack('q<')
        self[index, tmp.length] = tmp
      end

      # Little endian, unsigned

      def writeUInt16LE(i, index = self.length)
        tmp = [i].pack('S<')
        self[index, tmp.length] = tmp
      end

      def writeUInt32LE(i, index = self.length)
        tmp = [i].pack('L<')
        self[index, tmp.length] = tmp
      end

      def writeUInt64LE(i, index = self.length)
        tmp = [i].pack('Q<')
        self[index, tmp.length] = tmp
      end

      # Big endian, signed

      def writeInt16BE(i, index = self.length)
        tmp = [i].pack('s>')
        self[index, tmp.length] = tmp
      end

      def writeInt32BE(i, index = self.length)
        tmp = [i].pack('l>')
        self[index, tmp.length] = tmp
      end

      def writeInt64BE(i, index = self.length)
        tmp = [i].pack('q>')
        self[index, tmp.length] = tmp
      end

      # Big endian, unsigned

      def writeUInt16BE(i, index = self.length)
        tmp = [i].pack('S>')
        self[index, tmp.length] = tmp
      end

      def writeUInt32BE(i, index = self.length)
        tmp = [i].pack('L>')
        self[index, tmp.length] = tmp
      end

      def writeUInt64BE(i, index = self.length)
        tmp = [i].pack('Q>')
        self[index, tmp.length] = tmp
      end

      def writeUInt16NE(i, index = self.length)
        tmp = [i].pack('n')
        self[index, tmp.length] = tmp
      end

      def writeUInt32NE(i, index = self.length)
        tmp = [i].pack('N')
        self[index, tmp.length] = tmp
      end
    end
  end
end
