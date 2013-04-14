require 'net/sshd/callback-helpers'

class Net::SSHD::Callbacks
  on :connect do
    puts 'New connection'
    send_line(Net::SSHD::PROTO_VERSION)

    @kex = {
      cookie:       _random_string(16),
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
                :byte,       KEXINIT,
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

  on DISCONNECT do |packet|
    error   = packet.read_long
    message = packet.read_string
    puts "Disconnect (Error #{error}): #{message}"
  end

  on KEXINIT do |packet|
    @client_cookie = packet.read(16)
  end

  on KEXECDH_INIT do |packet|
    @client_key = packet.read_string
    puts "Got #{@client_key.length} byte key: #{@client_key.inspect}"
  end

  on :unknown do |packet|
    puts "Unimplemented packet type: #{packet.type}."
    puts "Packet payload:"
    p packet.content
    exit
  end
end
