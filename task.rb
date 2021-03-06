$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__)) unless $LOAD_PATH.include?(File.expand_path('../lib', __FILE__))
require 'celluloid/zmq/zap/version'
require 'digest/sha2'

gem_name = "celluloid-zmq-zap-#{Celluloid::ZMQ::ZAP::VERSION}.gem"
checksum = Digest::SHA2.new.hexdigest(File.read(gem_name))
checksum_path = "checksum/#{gem_name}.sha2"
File.open(checksum_path, 'w' ) {|f| f.write(checksum) }
