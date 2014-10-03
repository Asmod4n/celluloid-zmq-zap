# rubocop:disable all
module Celluloid
  module ZMQ
    module ReadableSocket
      def read_multipart(buffer = [])
        ZMQ.wait_readable(@socket) if ZMQ.evented?

        unless ::ZMQ::Util.resultcode_ok? @socket.recv_strings buffer
          raise IOError, "error receiving ZMQ string: #{::ZMQ::Util.error_string}"
        end
        buffer
      end
    end
  end
end
# rubocop:enable all
