require 'celluloid/zmq/zap/authenticators'
require 'redis'

module Celluloid
  module ZMQ
    module ZAP
      # Authenticators
      module Authenticators
        class Redis < AbstractAuthenticator
          def initialize(options = {})
            @redis = ::Redis.new(options)
          end

          private

          def null(domain, address, identity)
            user = @redis.hgetall("zap::null::#{identity}")
            if user['domain'] == domain && user['address'] == address
              user['username']
            else
              false
            end
          end

          def plain(username, password)
            user = @redis.hgetall("zap::plain::#{username}")
            if user['password'] == password
              user['username']
            else
              false
            end
          end

          def curve(public_key)
            @redis.get("zap::curve::#{public_key}")
          end
        end
      end
    end
  end
end
