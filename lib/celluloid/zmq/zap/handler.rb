require 'celluloid/zmq'

module Celluloid
  module ZMQ
    module ZAP
      # Handler
      class Handler
        include Celluloid::ZMQ
        include Celluloid::Logger

        finalizer :finalize

        def initialize(options = {})
          @authenticator = options.fetch(:authenticator) do
            require 'celluloid/zmq/zap/authenticators/null'
            Authenticators::Null.new
          end

          @socket = RouterSocket.new

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
          if delimiter
            servers, payload = messages[0, delimiter], messages[delimiter + 1..-1]
            if payload.size.between?(6, 9)

              version, request_id, domain, address,
              identity, mechanism, credentials = payload

              if version == '1.0'
                user = @authenticator.get(domain, address, identity,
                                          mechanism, credentials)

                if user
                  @socket << servers.concat(['', '1.0', request_id, '200',
                                             'OK', user, ''])
                else
                  @socket << servers.concat(['', '1.0', request_id, '400',
                                             'Identity is not known', '', ''])
                end
              else
                @socket << servers.concat(['', '1.0', request_id, '500',
                                           'Version number not valid', '', ''])
              end
            else
              @socket << servers.concat(['', '1.0', '1', '500',
                                         'Payload size not valid', '', ''])
            end
          else
            abort ArgumentError.new("Invalid message #{messages} recieved")
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
    end
  end
end
