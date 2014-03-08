module Celluloid
  module ZMQ
    module ZAP
      module Credentials
        class Null
          def get(domain, address, identity, mechanism, *credentials)
            'nobody'
          end
        end

        class Sequel
          def initialize(plain_model, curve_model)
            @plain, @curve = plain_model, curve_model
          end

          def get(domain, address, identity, mechanism, *credentials)
            case mechanism
            when 'PLAIN'
              @plain.select(:user).
                      where(:username => credentials[0],
                            :password => credentials[1])

            when 'CURVE'
              @curve.select(:user).
                      where(:public_key => credentials[0])

            else
              raise ArgumentError, "Unknown mechanism #{mechanism}"
            end
          end
        end

        class Redis
          def initialize(options = {})
            @redis = ::Redis.new(options)
          end

          def get(domain, address, identity, mechanism, *credentials)
            case mechanism
            when 'PLAIN'

              user = @redis.hgetall("#{mechanism.downcase}::#{credentials[0]}")
              if user['password'] == credentials[1]
                user['username']
              else
                false
              end

            when 'CURVE'
              @redis.get("#{mechanism.downcase}::#{credentials[0]}")
            else
              raise ArgumentError, "Unknown mechanism #{mechanism}"
            end
          end
        end
      end
    end
  end
end
