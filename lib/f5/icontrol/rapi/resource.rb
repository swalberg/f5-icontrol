module F5
  module Icontrol
    class RAPI
      class Resource
        def initialize(args, credentials)
          @args = args
          @credentials = credentials
        end

        def method_missing(method, *args, &block)
          if @args.key? method.to_s
            return @args[method.to_s]
          end

          potential_collection = "#{method}Reference"
          if @args.key? potential_collection
            link = @args[potential_collection]["link"]
            link.sub! %r{^https?://[A-Za-z0-9\-._]+/}, ""
            return F5::Icontrol::RAPI.new(link, @credentials)
          end
        end
      end
    end
  end
end
