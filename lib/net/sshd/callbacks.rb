require 'net/sshd/callback-helpers'
require 'net/ssh'

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

    send_packet(
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
    )
  end

  on DISCONNECT do |packet|
    code    = packet.read_long
    message = packet.read_string
    puts "Client disconnected: #{message} (#{code})"
  end

  on KEXINIT do |packet|
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
=begin
    @dhflags = {
      min:  packet.read_long,
      n:    packet.read_long,
      max:  packet.read_long
    }

    send_packet(
      :byte,  KEX_DH_REPLY,
      :mpint, dh.getPrime,
      :mpint, 2.chr,
    )
    dh.generateKeys
=end
  end

  on KEX_DH_GEX_INIT do |packet|
=begin
    e = packet.read_mpint
    dh.secret = dh.computeSecret(e)

    send_packet(
      :byte,    KEX__UNKNOWN_33,
      :string,  @host_public_key,
      :mpint,   dh.getPublicKey,
      :string,  sign_buffer(session)
    )
=end
  end

  on NEWKEYS do |packet|
=begin
    send_packet(:byte, 21)
    @keyson = true

    keysize = lambda do |salt|
      # TODO: dh.secret might need ot be encoded for SSH
      var sha = crypto.createHash('SHA256')
      sha.write(build_packet(:mpint, dh.secret) + @session + salt + @session)
      sha
    end

    #...
=end
  end

  on SERVICE_REQUEST do |packet|
    
  end

  on USERAUTH_REQUEST do |packet|
    
  end

  on GLOBAL_REQUEST do |packet|
    
  end

  on CHANNEL_OPEN do |packet|
    
  end

  on CHANNEL_EOF do |packet|
    
  end

  on CHANNEL_REQUEST do |packet|
    
  end

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

  on :unknown do |packet|
    puts "Unimplemented packet type: #{packet.type}."
    puts "Packet payload:"
    p packet.content
    exit
  end
end
