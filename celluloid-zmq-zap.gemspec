$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__)) unless $LOAD_PATH.include?(File.expand_path('../lib', __FILE__))
require 'celluloid/zmq/zap/version'

Gem::Specification.new do |gem|
  gem.authors       = %w[Hendrik Beskow]
  gem.email         = %w[hendrik@beskow.de]
  gem.description   = 'ZeroMQ Authentication Protocol in Ruby'
  gem.summary       = 'ØMQ zap handler'
  gem.homepage      = 'https://github.com/Asmod4n/celluloid-zmq-zap'
  gem.license       = 'Apache 2.0'

  gem.files         = [
    'lib/celluloid/zmq/zap.rb',
    'lib/celluloid/zmq/zap/version.rb',
    'lib/celluloid/zmq/zap/celluloid-zmq-ext.rb',
    'lib/celluloid/zmq/zap/credentials.rb',
    'lib/celluloid/zmq/zap/handler.rb',
    'LICENSE',
    'README.md'
  ]

  gem.name          = 'celluloid-zmq-zap'
  gem.require_paths = %w[lib]
  gem.version       = Celluloid::ZMQ::ZAP::VERSION

  gem.add_dependency 'celluloid-zmq', '>= 0.15'
  gem.add_development_dependency 'bundler', '>= 1.5'
  gem.signing_key = File.expand_path(File.join('~/.keys', 'gem-private_key.pem')) if $0 =~ /gem\z/
  gem.cert_chain = ['gem-public_cert.pem']
end
