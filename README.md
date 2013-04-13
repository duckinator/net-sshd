# Net::SSHD

Net::SSHD aims to be a generic SSH protocol server to be used as a
listener providing a transport layer for SSH connections.

The intent is to use it as a secure replacement for insecure plain text
TCP socket listeners to serve any arbitary "telnet" protocol encapsulated
in the ssh transport, preferrably supporting only public key authentication.

It would be nice to reuse as much of Net::SSH as possible.

The end goal would be to provide a full SSH implementation in Ruby, similar to
the Erlang SSH library, which also provides a daemon in addition to just the
client libraries.

References:
 - Erlang SSH library: http://www.erlang.org/doc/apps/ssh/
 - SSH Transport Layer RFC: http://www.ietf.org/rfc/rfc4253.txt
 - SSH Connection Layer RFC: http://www.ietf.org/rfc/rfc4254.txt
 - SSH Authentication Procotol RFC: http://www.ietf.org/rfc/rfc4252.txt

Testing:
 ruby test/test.rb
 ssh localhost -p 8022

## Installation

Add this line to your application's Gemfile:

    gem 'net-sshd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install net-sshd

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## History

Based on a [project of the same name](https://github.com/jammi/net-sshd) by Juha-Jarmo Heinonen ([jammi](https://github.com/jammi)).

