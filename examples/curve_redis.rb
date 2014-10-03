# run with ruby examples/curve_redis.rb

require 'bundler/setup'
require 'rbnacl'
require 'celluloid/zmq/zap'
require 'celluloid/zmq/zap/authenticators/redis'

Celluloid::ZMQ.init

$server_private_key = RbNaCl::PrivateKey.generate
$server_public_key  = $server_private_key.public_key
$client_private_key = RbNaCl::PrivateKey.generate
$client_public_key  = $client_private_key.public_key

redis = Redis.new
redis.set("zap::curve::#{$client_public_key}", 'client')
redis.quit

server = TCPServer.new('127.0.0.1', 0)
$bind_point = "tcp://127.0.0.1:#{server.addr[1]}"
server.close

class Server
  include Celluloid::ZMQ
  include Celluloid::Logger

  finalizer :finalize

  def initialize
    @socket = RouterSocket.new
    @socket.identity = 'server'
    @socket.set(::ZMQ::ZAP_DOMAIN, 'test')
    @socket.set(::ZMQ::CURVE_SERVER, 1)
    @socket.set(::ZMQ::CURVE_SECRETKEY, $server_private_key.to_s)

    begin
      @socket.bind($bind_point)
    rescue IOError
      @socket.close
      raise
    end

    async.run
  end

  def run
    loop { async.handle_messages @socket.read_multipart }
  end

  def handle_messages(messages)
    delimiter = messages.index('')
    if delimiter
      servers, payload = messages[0, delimiter], messages[delimiter+1..-1]
      debug '<server_read>'
      debug payload
      debug '</server_read>'
      debug '<server_write>'
      debug @socket << servers.concat(['', "Hello #{servers.first} #{payload}"])
      debug '</server_write>'
    end
  end

  def finalize
    @socket.close if @socket
  end

  def terminate
    finalize
    super
  end
end

class Client
  include Celluloid::ZMQ
  include Celluloid::Logger

  finalizer :finalize

  def initialize
    @socket = DealerSocket.new
    @socket.identity = 'client'
    @socket.set(::ZMQ::ZAP_DOMAIN, 'test')
    @socket.set(::ZMQ::CURVE_SERVERKEY, $server_public_key.to_s)
    @socket.set(::ZMQ::CURVE_PUBLICKEY, $client_public_key.to_s)
    @socket.set(::ZMQ::CURVE_SECRETKEY, $client_private_key.to_s)

    begin
      @socket.connect($bind_point)
    rescue IOError
      @socket.close
      raise
    end

    async.run
    async.write("Hello #{rand(1..100)}")
    async.write("Hello #{rand(1..100)}")
    async.write("Hello #{rand(1..100)}")
    async.write("Hello #{rand(1..100)}")
    async.write("Hello #{rand(1..100)}")
  end

  def run
    loop { async.handle_messages @socket.read_multipart }
  end

  def handle_messages(messages)
    debug '<client_read>'
    debug messages
    debug '</client_read>'
  end

  def write(*messages)
    debug '<client_write>'
    debug @socket << [''].concat(messages)
    debug '</client_write>'
    true
  end

  def finalize
    @socket.close if @socket
  end

  def terminate
    finalize
    super
  end
end

Celluloid::ZMQ::ZAP::Handler.supervise_as :handler, authenticator: Celluloid::ZMQ::ZAP::Authenticators::Redis.new

Server.supervise_as :server
Client.new
sleep 0.2
