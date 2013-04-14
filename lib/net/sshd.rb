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
        buffer.writeRaw(payload, 5)
        #buffer.fill(0, 5 + payload.length) # It's filled with NULLs from the start. This is unnecessary.
        send_data(buffer)
      end

      def get_packet(packet)
        type = packet.getType
        case type
        when MSG::DISCONNECT  # Disconnect
          error   = packet.readUInt32
          message = packet.readString
          puts "Disconnect (Error #{error}): #{message}"
        when MSG::KEXINIT # kexinit
          @client_cookie = packet.readBuffer(16)
          @kex = {
            cookie:       'asdfasdfasdfasdf', # TODO: Generate an actual cookie.
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
            firstKexFollows: packet.readUInt8 > 0, # TODO: Figure this out ourselves, because we're supposed to send KEXINIT first.
          }

          buf = Buffer.new
          buf.pack(
                    { byte:       MSG::KEXINIT       },
                    { raw:        @kex[:cookie]      },
                    { name_list:  @kex[:kexAlgs]     },
                    { name_list:  @kex[:encAlgs][:client2server] },
                    { name_list:  @kex[:encAlgs][:server2client] },
                    { name_list:  @kex[:macAlgs][:client2server] },
                    { name_list:  @kex[:macAlgs][:server2client] },
                    { name_list:  @kex[:cprAlgs][:client2server] },
                    { name_list:  @kex[:cprAlgs][:server2client] },
                    { name_list:  @kex[:langs][:client2server]   },
                    { name_list:  @kex[:langs][:server2client]   },
                    { bool:   @kex[:firstKexFollows] },
                    { uint32: 0                      },
                  )
          send_payload(buf)
        when MSG::KEXECDH_INIT
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

