module Celluloid
  module ZMQ
    module ZAP
      # Authenticators
      module Authenticators
        class AbstractAuthenticator
          def get(domain, address, identity, mechanism, credentials)
            case mechanism
            when 'NULL'
              null(domain, address, identity)
            when 'PLAIN'
              plain(credentials.first, credentials.last)
            when 'CURVE'
              curve(credentials.first)
            else
              fail ArgumentError, "Unknown mechanism #{mechanism}"
            end
          end

          private

          def null(domain, address, identity)
            fail NotImplementedError
          end

          def plain(username, password)
            fail NotImplementedError
          end

          def curve(public_key)
            fail NotImplementedError
          end
        end
      end
    end
  end
end
