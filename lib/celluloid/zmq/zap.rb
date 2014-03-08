require 'celluloid/zmq'

module Celluloid
  module ZMQ
    # namespace
    module ZAP
    end
  end
end

require 'celluloid/zmq/zap/version'
if Celluloid::ZMQ::VERSION == '0.15.0'
  require 'celluloid/zmq/zap/celluloid-zmq-ext'
end
require 'celluloid/zmq/zap/credentials'
require 'celluloid/zmq/zap/handler'
