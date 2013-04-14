class Net::SSHD::Callbacks
  include Net::SSHD::MSG

  def self.on(packet_type, &block)
    @@handlers ||= Array.new(101)
    @@handlers[packet_type] = block
  end

  def self.handle(listener, packet)
    packet_type = packet.type
    packet_type = UNKNOWN if @@handlers[packet_type].nil?
    listener.instance_eval { @@handlers[packet_type].call(packet) }
  end
end
