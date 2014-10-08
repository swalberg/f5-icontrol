module F5
  module Cli
    class Config
      def self.host
        config["host"]
      end

      def self.username
        config["username"]
      end

      def self.password
        config["password"]
      end

      def self.config
        @@config ||= YAML.load_file("#{ENV['HOME']}/.f5.yml")
      end
    end
  end
end
