module F5
  module Icontrol
    class REST
      def raise_error(e)
        case e.http_code
        when 400
          raise F5::Icontrol::REST::BadRequest, e.exception
        when 401
          raise F5::Icontrol::REST::Unauthorized, e.exception
        when 403
          raise F5::Icontrol::REST::Forbidden, e.exception
        when 404
          raise F5::Icontrol::REST::NotFound, e.exception
        when 409
          raise F5::Icontrol::REST::Conflict, e.exception
        when 415
          raise F5::Icontrol::REST::Malformed, e.exception
        when 500
          raise F5::Icontrol::REST::InternalError, e.exception
        when 501
          raise F5::Icontrol::REST::NotImplemented, e.exception
        else # raise the error as is
          raise e
        end
      end

      class Error < ::StandardError
        attr_reader :http_code
        attr_reader :http_body
        attr_reader :http_headers
        attr_writer :message

        def initialize(e)
          @message = e.message
          @http_code = e.http_code || nil
          @http_body = e.http_body || nil
          @http_headers = e.http_headers || nilREs
        end

        def to_s
          message
        end

        def message
          @message || default_message
        end

        def default_message
          self.class.name
        end
      end

      class ParameterError < Error; end # 4XX Errors parent

      class ServerError < Error; end # 5XX Errors parent

      class BadRequest < ParameterError; end   # 400
      class Unauthorized < ParameterError; end # 401
      class Forbidden < ParameterError; end    # 403
      class NotFound < ParameterError; end     # 404
      class Conflict < ParameterError; end     # 409
      class Malformed < ParameterError; end    # 415

      class InternalError < ServerError; end   # 500
      class NotImplemented < ServerError; end  # 501
    end
  end
end
