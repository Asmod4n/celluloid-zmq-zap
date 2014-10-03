﻿require 'celluloid/zmq'

module Celluloid
  module ZMQ
    # namespace
    module ZAP
    end
  end
end

require 'celluloid/zmq/zap/version'
if Celluloid::ZMQ::VERSION == '0.16.0'
  require 'celluloid/zmq/zap/celluloid-zmq-ext'
end
require 'celluloid/zmq/zap/authenticators'
require 'celluloid/zmq/zap/handler'
