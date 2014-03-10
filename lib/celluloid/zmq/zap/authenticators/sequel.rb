require 'celluloid/zmq/zap/authenticators'

module Celluloid
  module ZMQ
    module ZAP
      # Authenticators
      module Authenticators
        class Sequel < AbstractAuthenticator
          def initialize(null_model, plain_model, curve_model)
            @null, @plain, @curve = null_model, plain_model, curve_model
          end

          private

          def null(domain, address, identity)
            @null.select(:username)
                  .where(domain:   domain,
                         address:  address,
                         identity: identity)
          end

          def plain(username, password)
            @plain.select(:username)
                   .where(username: credentials.first,
                          password: credentials.last)
          end

          def curve(public_key)
            @curve.select(:username)
                   .where(public_key: public_key)
          end
        end
      end
    end
  end
end
