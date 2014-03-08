require 'celluloid'

module Celluloid
  module ZMQ
    module ZAP
      # Credentials
      module Credentials
        # Null
        class Null
          include Celluloid::Logger

          def get(domain, address, identity, mechanism, *credentials)
            'nobody'
          end
        end

        # Sequel
        class Sequel
          def initialize(null_model, plain_model, curve_model)
            @null, @plain, @curve = null_model, plain_model, curve_model
          end

          def get(domain, address, identity, mechanism, *credentials)
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

        # Redis
        class Redis
          def initialize(options = {})
            @redis = ::Redis.new(options)
          end

          def get(domain, address, identity, mechanism, *credentials)
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

          def curve(identity, public_key)
            user = @redis.hgetall("zap::curve::#{identity}")
            if user['public_key'] == public_key
              user['username']
            else
              false
            end
          end
        end
      end
    end
  end
end
