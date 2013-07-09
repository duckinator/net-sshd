require 'net/sshd/callback-helpers'
require 'net/ssh'
require 'openssl'

# node.js: getPrime, generateKeys, computeSecret, getPublicKey
# OpenSSL::PKey::DH: p, g, generate, compute_key, pub_key

class Net::SSHD::Callbacks
  on :connect do |packet|
    puts 'New connection'
    send_line(Net::SSHD::PROTO_VERSION)

    @server_kex = {
      cookie:       _random_string(16),
      kexAlgs:      ['diffie-hellman-group-exchange-sha256'],
      #kexAlgs:      Net::SSH::Transport::Kex::MAP.keys,
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

    response = [
      :byte,       KEXINIT,
      :raw,        @server_kex[:cookie],
      :string,     @server_kex[:kexAlgs],
      :string,     @server_kex[:hostKeyAlgs],
      :string,     @server_kex[:encAlgs][:client2server].join(','),
      :string,     @server_kex[:encAlgs][:server2client].join(','),
      :string,     @server_kex[:macAlgs][:client2server].join(','),
      :string,     @server_kex[:macAlgs][:server2client].join(','),
      :string,     @server_kex[:cprAlgs][:client2server].join(','),
      :string,     @server_kex[:cprAlgs][:server2client].join(','),
      :string,     @server_kex[:langs][:client2server].join(','),
      :string,     @server_kex[:langs][:server2client].join(','),
      :bool,       @server_kex[:firstKexFollows],
      :long,       0, # Reserved (supposed to be 0)
    ]

    @server_algorithm_packet = build_packet(*response)
    send_packet(*response)
  end

  on DISCONNECT do |packet|
    code    = packet.read_long
    message = packet.read_string
    puts "Client disconnected: #{message} (#{code})"
  end

  on KEXINIT do |packet|
    @client_algorithm_packet = packet.payload[0..-2]

    @client_kex = {
      cookie:      packet.read(16),
      kexAlgs:     packet.read_list,
      hostKeyAlgs: packet.read_list,
      encAlgs:     [packet.read_list, packet.read_list],
      macAlgs:     [packet.read_list, packet.read_list],
      cprAlgs:     [packet.read_list, packet.read_list],
      langs:       [packet.read_list, packet.read_list],
      firstKexFollows: packet.read_bool,
    }
  end

  on KEX_DH_GEX_REQUEST do |packet|
    @dhflags = {
      min:  packet.read_long,
      n:    packet.read_long,
      max:  packet.read_long
    }

    @dh = OpenSSL::PKey::DH.new
    @dh.p = OpenSSL::BN.new(Net::SSHD::Groups::MODP2, 2)
    @dh.g = 2

    send_packet(
      :byte,   KEX_DH_REPLY,
      :bignum, @dh.p,
      :bignum, OpenSSL::BN.new(@dh.g.to_s),
    )
    @dh.generate_key!
  end

  on KEX_DH_GEX_INIT do |packet|
    e = packet.read_bignum
    @dh_secret = @dh.compute_key(e)

    hash_in = [
      :string, @client_version,
      :string, Net::SSHD::PROTO_VERSION,
      :string, @client_algorithm_packet,
      :string, @server_algorithm_packet,

      :string, @hostkey_pub,

      :bignum, e,
      :bignum, @dh.pub_key,
      :bignum, OpenSSL::BN.new(@dh_secret, 2),
    ]

    sha = OpenSSL::Digest::SHA256.new
    @session = sha.digest(build_packet(*hash_in))

    send_packet(
      :byte,    KEX_DH_GEX_REPLY,
      :string,  @hostkey_pub,
      :bignum,  @dh.pub_key,
      :string,  sign_buffer(@session),
    )
  end
=begin
  on NEWKEYS do |packet|
    send_packet(:byte, 21)
    @keyson = true

    keysize = lambda do |salt|
      # TODO: @dh_secret might need to be encoded for SSH
      sha = OpenSSL::Digest::SHA256.new
      sha <<  build_packet(
                :bignum, @dh_secret,
                :string, @session,
                :string, salt,
                :string, @session,
              )
      sha
    end

    #...
  end
=end

#  on SERVICE_REQUEST do |packet|
    
#  end

#  on USERAUTH_REQUEST do |packet|
    
#  end

#  on GLOBAL_REQUEST do |packet|
    
#  end

#  on CHANNEL_OPEN do |packet|
    
#  end

#  on CHANNEL_EOF do |packet|
    
#  end

#  on CHANNEL_REQUEST do |packet|
    
#  end

=begin
  on CHANNEL_DATA do |packet|
    chan = packet.read_long
    data = packet.read_string

    if @proc
      # Javascript version:
      #while(data.length) {
      # proc.stdin.write(data.slice(0, 512));
      # data = data.slice(512);
      #}
      return
    end

    case data
    when "\u0004"
      send_packet(
        :byte,    CHANNEL_DATA,
        :long,    chan,
        :string,  "Hit q to exit\r\n",
      )
    when "q"
      send_packet(
        :byte,    CHANNEL_DATA,
        :long,    chan,
        :string,  "Goodbye, <insert $USER here>\r\n",
      )
      # Set exit status to 0
      send_packet(
        :byte,    CHANNEL_REQUEST,
        :long,    chan,
        :string,  "exit-status",
        :bool,    false,
        :long,    0,
      )
      send_packet(
        :byte,    CHANNEL_CLOSE,
        :long,    chan,
      )
    else
      send_packet(
        :byte,    CHANNEL_DATA,
        :long,    chan,
        :string,  "You hit #{data}\r\n"
      )
    end
  end
=end

  on :unknown do |packet|
    packet_type_name =
      Net::SSHD::Constants::MSG.constants.select do |const|
        Net::SSHD::Constants::MSG.const_get(const) == packet.type
      end.first.to_s

    puts "Unimplemented packet type: #{packet_type_name} (#{packet.type})."
    puts "Packet payload:"
    p packet.content
    exit
  end
end
