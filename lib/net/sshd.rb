require 'net/sshd/version'
require 'net/sshd/buffer'
require 'net/sshd/packet'
require 'net/ssh'
require 'eventmachine'
require 'pp'
require 'hexy'

module Net
  module SSHD
    #RAND_GEN = File.open('/dev/urandom','rb'){|f| f.read(4096) }
    PROTO_VERSION = "SSH-2.0-Ruby/Net::SSHD_%s %s" % [Net::SSH::Version::CURRENT, RUBY_PLATFORM]

    class Listen < EM::Connection
      def initialize(*args)
        @mac_length = 0
        @kex    = nil

        super(*args)

        puts 'New connection'
        send_line(PROTO_VERSION)
      end

      def send_line(str)
        send_data(str + "\r\n")
      end

      def hexy(str)
        puts Hexy.new(str).to_s
      end

      def send_payload(payload)
        pad_length = (8 - ((5 + payload.length) % 8))
        buffer     = Buffer.new(5 + payload.length + pad_length + @mac_length)

        buffer.writeUInt32BE(payload.length + 1 + pad_length, 0)
        buffer.writeUInt8(pad_length, 4)
        buffer.writeString(payload, 5)
        #buffer.fill(0, 5 + payload.length) # It's filled with NULLs from the start. This is unnecessary.
        send_data(buffer)
      end

      def get_packet(packet)
        type = packet.getType
        case type
        when 1  # Disconnect
          error   = packet.readUInt32
          message = packet.readString
          puts "Disconnect (Error #{error}): #{message}"
        when 20 # kexinit
          send_payload(packet.payload) # agree to whatever #TODO
          @kex = {
            cookie: packet.readBuffer(16),
            kexAlgs:     ['diffie-hellman-group-exchange-sha256'],
            hostKeyAlgs: ['ssh-rsa'],
            encAlgs:     [['aes128-ctr'], ['aes128-ctr']],
            macAlgs:     [['hmac-md5'],   ['hmac-md5']],
            cprAlgs:     [['none'],       ['none']],
            langs:       [[], []],
            firstKexFollows: packet.readUInt8 > 1,
          }
        when 30 # KEXECDH_INIT
          @client_key = packet.readBuffer
          puts "Got #{@client_key.length} byte key: #{@client_key.inspect}"
        else
          puts "Unimplemented packet type: #{type}."
          puts "Packet payload:"
          p packet.payload
          exit
        end
      end

      def bye(delay_ms = 0)
        EM.add_timer(delay_ms/1000.0) do
          close_connection_after_writing
        end
      end

      def receive_data(data)
#        puts "data [#{data.size}]: #{data.inspect}"
#        @buffer += data
#        process_packets

        if data[0, 4] === 'SSH-'
          puts "Client header: #{data}"
        else
          packet = Packet.new(data, @mac_length)
          puts "Received #{packet.getType} packet"
          get_packet(packet)
        end
      end
    end

    def self.start(host, port, *args)
      EM.start_server(host, port, Listen, *args)
    end
  end
end

