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
        Callbacks.handle(self, nil, :connect)
      end

      def _random_string(length)
        SecureRandom.random_bytes(length)
      end

      def send_line(str)
        send_data(str + "\r\n")
      end

      def send_payload(payload)
        pad_length = (8 - ((5 + payload.length) % 8))
        pad_length += 8 if pad_length < 8
        padding = _random_string(pad_length)

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

