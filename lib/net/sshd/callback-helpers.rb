class Net::SSHD::Callbacks
  include Net::SSHD::Constants::MSG

  def self.on(packet_type = nil, &block)
    @@handlers ||= {}

    @@handlers[packet_type] = block
  end

  def self.handle(listener, packet, type = nil)
    packet_type = type || packet.type

    if @@handlers.keys.include?(packet_type)
      listener.instance_exec(packet, &@@handlers[packet_type])
    else
      handle(listener, packet, :unknown)
    end
  end
end
