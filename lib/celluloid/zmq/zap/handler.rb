require 'celluloid/zmq'

module Celluloid
  module ZMQ
    module ZAP
      class Handler
        include Celluloid::ZMQ

        finalizer :finalize

        def initialize(options = {})
          @authenticator = options.fetch(:authenticator, Credentials::Null).new

          @socket = RouterSocket.new
          @socket.set(::ZMQ::ZAP_DOMAIN, options.fetch(:domain, 'test'))
          @socket.identity = options.fetch(:identity, 'zeromq.zap.01')

          begin
            @socket.bind('inproc://zeromq.zap.01')
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
          servers, payload = messages[0, delimiter], messages[delimiter+1..-1]
          if payload.size.between?(6, 9)
            version, request_id, domain, address, identity, mechanism, credentials = payload
            if version == '1.0'
              if user = @authenticator.get(domain, address, identity, mechanism, credentials)
                @socket << servers.concat(['', '1.0', request_id, '200', 'OK', user, ''])
              else
                @socket << servers.concat(['', '1.0', request_id, '400', 'Identity is not known', '', ''])
              end
            else
              @socket << servers.concat(['', '1.0', request_id, '500', 'Version number not valid', '', ''])
            end
          else
            @socket << servers.concat(['', '1.0', '1', '500', 'Payload size not valid', '', ''])
          end
        end

        def finalizer
          if @socket
            @socket.close
            @socket = nil
          end
        end

        def terminate
          finalize
          super
        end
      end
    end
  end
end
