require 'net/sshd/version'
require 'net/sshd/constants'
require 'net/sshd/buffer'
require 'net/sshd/packet'
require 'net/ssh'
require 'eventmachine'
require 'pp'
require 'hexy'

module Net
  module SSHD
    #RAND_GEN = File.open('/dev/urandom','rb'){|f| f.read(4096) }
    PROTO_VERSION = "SSH-2.0-Ruby/Net::SSHD_%s %s" % [Net::SSHD::VERSION, RUBY_PLATFORM]

    class Listen < EM::Connection
      def initialize(*args)
        @mac_length = 0
        @kex    = nil

        super(*args)

        puts 'New connection'
        send_line(PROTO_VERSION)
      end

      # TODO: Generate a random cookie.
      def _generate_cookie
        'asdfasdfasdfasdf'
      end

      def kexinit
        @kex = {
          cookie:       _generate_cookie,
          kexAlgs:      ['diffie-hellman-group-exchange-sha256'],
          hostKeyAlgs:  ['ssh-rsa'],
          encAlgs:      {
                          client2server: ['aes128-ctr'],
                          server2client: ['aes128-ctr'],
                        },
          macAlgs:      {
                          client2server: ['hmac-md5'],
                          server2client: ['hmac-md5'],
                        },
          cprAlgs:      {
                          client2server: ['none'],
                          server2client: ['none'],
                        },
          langs:        {
                          client2server: [],
                          server2client: [],
                        },
          firstKexFollows: false, # ?
          #firstKexFollows: packet.readUInt8 > 0, # TODO: Figure this out ourselves, because we're supposed to send KEXINIT first.
        }

        buffer =  Net::SSH::Buffer.from(
                    :byte,       MSG::KEXINIT,
                    :raw,        @kex[:cookie],
                    :string,     @kex[:kexAlgs],
                    :string,     @kex[:encAlgs][:client2server].join(','),
                    :string,     @kex[:encAlgs][:server2client].join(','),
                    :string,     @kex[:macAlgs][:client2server].join(','),
                    :string,     @kex[:macAlgs][:server2client].join(','),
                    :string,     @kex[:cprAlgs][:client2server].join(','),
                    :string,     @kex[:cprAlgs][:server2client].join(','),
                    :string,     @kex[:langs][:client2server].join(','),
                    :string,     @kex[:langs][:server2client].join(','),
                    :bool,       @kex[:firstKexFollows],
                    :long,       0,
                  )
        send_payload(buffer)
      end

      def send_line(str)
        send_data(str + "\r\n")
      end

      def hexy(str)
        puts Hexy.new(str).to_s
      end

      def send_payload(payload)
        pad_length = (8 - ((5 + payload.length) % 8))
        pad_length += 8 if pad_length < 8
        padding = "\x01" * pad_length # TODO: Make this a random string
#        buffer     = Buffer.new(5 + payload.length + pad_length + @mac_length)

#        buffer.writeUInt32BE(payload.length + 1 + pad_length, 0)
#        buffer.writeUInt8(pad_length, 4)
#        buffer.writeRaw(payload, 5)
        #buffer.fill(0, 5 + payload.length) # It's filled with NULLs from the start. This is unnecessary.
#p buffer
        buffer =  Net::SSH::Buffer.from(
                    :long, payload.length + 1 + pad_length,
                    :byte, pad_length,
                    :raw,  payload,
                    :raw,  padding,
                  )
        send_data(buffer.content)
      end

      def get_packet(packet)
        type = packet.type
        case type
        when MSG::DISCONNECT  # Disconnect
          error   = packet.read_long
          message = packet.read_string
          puts "Disconnect (Error #{error}): #{message}"
        when MSG::KEXINIT # kexinit
          @client_cookie = packet.read(16)
        when MSG::KEXECDH_INIT
          @client_key = packet.read_string
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
          kexinit
        else
          packet = Packet.new(data, @mac_length)
          puts "Received #{packet.type} packet"
          get_packet(packet)
        end
      end
    end

    def self.start(host, port, *args)
      EM.start_server(host, port, Listen, *args)
    end
  end
end

