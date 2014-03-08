require 'celluloid/zmq'

module Celluloid::ZMQ::ZAP
end

require 'celluloid/zmq/zap/version'
require 'celluloid/zmq/zap/celluloid-zmq-ext' if Celluloid::ZMQ::VERSION == "0.15.0"
require 'celluloid/zmq/zap/credentials'
require 'celluloid/zmq/zap/handler'
