require "spring_standalone/version"

module SpringStandalone
  module Client
    class Version < Command
      def call
        puts "SpringStandalone version #{SpringStandalone::VERSION}"
      end
    end
  end
end
