require 'celluloid'

module Celluloid
  module ZMQ
    module ZAP
      # Authenticators
      module Authenticators
        # Null
        class Null
          include Celluloid::Logger

          def get(domain, address, identity, mechanism, *credentials)
            debug "domain:#{domain} address:#{address} identity:#{identity} mechanism:#{mechanism} credentials:#{credentials}"
            'nobody'
          end
        end
      end
    end
  end
end
