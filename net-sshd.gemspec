# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'net/sshd/version'

Gem::Specification.new do |spec|
  spec.name          = "net-sshd"
  spec.version       = Net::SSHD::VERSION
  spec.authors       = ["Nick Markwell"]
  spec.email         = ["nick@duckinator.net"]
  spec.description   = %q{SSH server written in ruby.}
  spec.summary       = %q{SSH server written in ruby.}
  spec.homepage      = "https://github.com/duckinator/net-sshd"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-ssh",      "~> 2.6.7"
  spec.add_runtime_dependency "eventmachine", "~> 1.0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
