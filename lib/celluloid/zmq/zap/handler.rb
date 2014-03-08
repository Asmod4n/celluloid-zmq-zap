require 'celluloid/zmq'
require 'celluloid/zmq/zap/credentials'

module Celluloid
  module ZMQ
    module ZAP
      # Handler
      class Handler
        include Celluloid::ZMQ

        finalizer :finalize

        def initialize(options = {})
          @authenticator = options.fetch(:authenticator, Credentials::Null).new

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

        def handle_messages(messages) # rubocop:disable MethodLength
          dlm = messages.index('')
          servers, payload = messages[0, dlm], messages[dlm + 1..-1]
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
