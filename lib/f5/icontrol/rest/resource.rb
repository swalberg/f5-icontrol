module F5
  module Icontrol
    class REST
      class Resource
        def initialize(args, credentials)
          @args = args
          @credentials = credentials
        end

        def method_missing(method, *args, &block)
          # If the method called match a property, return it
          if @args.key? method.to_s
            return @args[method.to_s]
          end
          
          # If the method called match a collection property, return a REST instance to this subcollection
          potential_collection = "#{method}Reference"
          if @args.key? potential_collection
            link = @args[potential_collection]["link"]
            link.sub! %r{^https?://[A-Za-z0-9\-._]+/}, ""
            link.sub! %r{\?ver=.*}, "" # remove trailing api version to allow chaining
            return F5::Icontrol::REST.new(link, @credentials)
          end
          
          # If the resource has a selfLink, return a REST instance on itself to allow update/delete
          if @args.key? 'selfLink'
            link = @args['selfLink']
            link.sub! %r{^https?://[A-Za-z0-9\-._]+/}, ""
            link.sub! %r{\?ver=.*}, "" # remove trailing api version to allow chaining
            F5::Icontrol::REST.new(@args['selfLink'], @credentials).send(method, args[0])
          end
        end
      end
    end
  end
end
