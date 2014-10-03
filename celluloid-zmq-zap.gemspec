$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'celluloid/zmq/zap/version'

Gem::Specification.new do |gem|
  gem.authors       = 'Hendrik Beskow'
  gem.description   = 'ZeroMQ Authentication Protocol in Ruby'
  gem.summary       = 'ØMQ zap handler'
  gem.homepage      = 'https://github.com/Asmod4n/celluloid-zmq-zap'
  gem.license       = 'Apache-2.0'

  gem.files         = [
    'lib/celluloid/zmq/zap.rb',
    'lib/celluloid/zmq/zap/version.rb',
    'lib/celluloid/zmq/zap/celluloid-zmq-ext.rb',
    'lib/celluloid/zmq/zap/authenticators.rb',
    'lib/celluloid/zmq/zap/authenticators/null.rb',
    'lib/celluloid/zmq/zap/authenticators/redis.rb',
    'lib/celluloid/zmq/zap/authenticators/sequel.rb',
    'lib/celluloid/zmq/zap/handler.rb',
    'LICENSE',
    'README.md'
  ]

  gem.name          = 'celluloid-zmq-zap'
  gem.version       = Celluloid::ZMQ::ZAP::VERSION

  gem.add_dependency 'celluloid-zmq', '>= 0.16'
  gem.add_development_dependency 'bundler', '>= 1.7'
end
