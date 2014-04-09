require "savon"
module F5
  class Icontrol
    class System
      class SystemInfo < F5::Icontrol
        def method_missing(method, args = nil, &block)
          if respond_to? method
            response_key = "#{method.to_s}_response".to_sym

            response = client("System.SystemInfo").call(method) do
              if args
                message args
              end
            end

            response.to_hash[response_key][:return]
          end
        end

        def respond_to?(method)
          client("System.SystemInfo").operations.include? method
        end

      end
    end
  end
end
