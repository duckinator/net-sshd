require 'net/sshd/callback-helpers'

class Net::SSHD::Callbacks
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

  on UNKNOWN do |packet|
    puts "Unimplemented packet type: #{packet.type}."
    puts "Packet payload:"
    p packet.content
    exit
  end
end
