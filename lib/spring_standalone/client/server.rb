module SpringStandalone
  module Client
    class Server < Command
      def self.description
        "Explicitly start a SpringStandalone server in the foreground"
      end

      def call
        require "spring_standalone/server"
        SpringStandalone::Server.boot(foreground: foreground?)
      end

      def foreground?
        !args.include?("--background")
      end
    end
  end
end
