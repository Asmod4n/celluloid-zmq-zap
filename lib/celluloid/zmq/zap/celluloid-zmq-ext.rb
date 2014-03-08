module Celluloid
  module ZMQ
    def self.evented?
      actor = Thread.current[:celluloid_actor]
      actor.mailbox.is_a?(Celluloid::ZMQ::Mailbox)
    end

    def wait_readable(socket)
      if ZMQ.evented?
        mailbox = Thread.current[:celluloid_mailbox]
        mailbox.reactor.wait_readable(socket)
      else
        raise ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end


    def wait_writable(socket)
      if ZMQ.evented?
        mailbox = Thread.current[:celluloid_mailbox]
        mailbox.reactor.wait_writable(socket)
      else
        raise ArgumentError, "unable to wait for ZMQ sockets outside the event loop"
      end
      nil
    end

    class Socket
      def set(option, value, length = nil)
        unless ::ZMQ::Util.resultcode_ok? @socket.setsockopt(option, value, length)
          raise IOError, "couldn't set value for option #{option}: #{::ZMQ::Util.error_string}"
        end
      end

      def get(option)
        option_value = []

        unless ::ZMQ::Util.resultcode_ok? @socket.getsockopt(option, option_value)
          raise IOError, "couldn't get value for option #{option}: #{::ZMQ::Util.error_string}"
        end

        option_value[0]
      end
    end

    module ReadableSocket
      def read_multipart(buffer = [])
        ZMQ.wait_readable(@socket) if ZMQ.evented?

        unless ::ZMQ::Util.resultcode_ok? @socket.recv_strings buffer
          raise IOError, "error receiving ZMQ string: #{::ZMQ::Util.error_string}"
        end
        buffer
      end
    end

    module WriteableSocket
      def write(*messages)
        ZMQ.wait_writable(@socket) if ZMQ.evented?

        unless ::ZMQ::Util.resultcode_ok? @socket.send_strings messages.flatten
          raise IOError, "error sending 0MQ message: #{::ZMQ::Util.error_string}"
        end

        messages
      end
    end
  end
end
