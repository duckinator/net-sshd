require 'net/sshd/version'
require 'net/ssh'
require 'net/sshd/constants'
require 'net/sshd/packet'
require 'net/sshd/callbacks'
require 'eventmachine'
require 'securerandom'
require 'pp'

module Net
  module SSHD
    #RAND_GEN = File.open('/dev/urandom','rb'){|f| f.read(4096) }
    PROTO_VERSION = "SSH-2.0-Ruby/Net::SSHD_%s %s" % [Net::SSHD::VERSION, RUBY_PLATFORM]

    class Listen < EM::Connection
      def initialize(*args)
        @mac    = ''
        @kex    = nil

        super(*args)

        puts 'New connection'
        send_line(PROTO_VERSION)
      end

      # TODO: Generate a random cookie.
      def _generate_cookie
        SecureRandom.random_bytes(16)
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
          firstKexFollows: false,
        }

        buffer =  Net::SSH::Buffer.from(
                    :byte,       MSG::KEXINIT,
                    :raw,        @kex[:cookie],
                    :string,     @kex[:kexAlgs],
                    :string,     @kex[:hostKeyAlgs],
                    :string,     @kex[:encAlgs][:client2server].join(','),
                    :string,     @kex[:encAlgs][:server2client].join(','),
                    :string,     @kex[:macAlgs][:client2server].join(','),
                    :string,     @kex[:macAlgs][:server2client].join(','),
                    :string,     @kex[:cprAlgs][:client2server].join(','),
                    :string,     @kex[:cprAlgs][:server2client].join(','),
                    :string,     @kex[:langs][:client2server].join(','),
                    :string,     @kex[:langs][:server2client].join(','),
                    :bool,       @kex[:firstKexFollows],
                    :long,       0, # Reserved (supposed to be 0)
                  )
        send_payload(buffer.content)
      end

      def send_line(str)
        send_data(str + "\r\n")
      end

      def send_payload(payload)
        pad_length = (8 - ((5 + payload.length) % 8))
        pad_length += 8 if pad_length < 8
        padding = "\x01" * pad_length # TODO: Make this a random string

        buffer =  Net::SSH::Buffer.from(
                    :long, payload.length + 1 + pad_length,
                    :byte, pad_length,
                    :raw,  payload,
                    :raw,  padding,
                    :raw,  @mac,
                  )

        puts ">> Type ?? - #{payload.length} bytes"
        send_data(buffer.content)
      end

      def bye(delay_ms = 0)
        EM.add_timer(delay_ms/1000.0) do
          close_connection_after_writing
        end
      end

      def receive_data(data)
        if data[0, 4] === 'SSH-'
          puts "Client header: #{data}"
          kexinit
        else
          packet = Packet.new(data, @mac.length)
          @mac   = packet.mac.to_s
          puts "<< Type #{packet.type} - #{packet.content.length} bytes"
          Callbacks.handle(self, packet)
        end
      end
    end

    def self.start(host, port, *args)
      EM.start_server(host, port, Listen, *args)
    end
  end
end

