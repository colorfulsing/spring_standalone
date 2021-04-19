require "spring_standalone/version"

module SpringStandalone
  module Client
    class Stop < Command
      def self.description
        "Stop all SpringStandalone processes for this project."
      end

      def call
        case env.stop
        when :stopped
          puts "SpringStandalone stopped."
        when :killed
          $stderr.puts "SpringStandalone did not stop; killing forcibly."
        when :not_running
          puts "SpringStandalone is not running"
        end
      end
    end
  end
end
