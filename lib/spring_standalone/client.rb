require "spring_standalone/errors"
require "spring_standalone/json"

require "spring_standalone/client/command"
require "spring_standalone/client/run"
require "spring_standalone/client/help"
require "spring_standalone/client/binstub"
require "spring_standalone/client/stop"
require "spring_standalone/client/status"
#require "spring_standalone/client/rails"
require "spring_standalone/client/version"
require "spring_standalone/client/server"

module SpringStandalone
  module Client
    COMMANDS = {
      "help"      => Client::Help,
      "-h"        => Client::Help,
      "--help"    => Client::Help,
      "binstub"   => Client::Binstub,
      "stop"      => Client::Stop,
      "status"    => Client::Status,
      # "rails"     => Client::Rails,
      "-v"        => Client::Version,
      "--version" => Client::Version,
      "server"    => Client::Server,
    }

    def self.run(args)
      command_for(args.first).call(args)
    rescue CommandNotFound
      Client::Help.call(args)
    rescue ClientError => e
      $stderr.puts e.message
      exit 1
    end

    def self.command_for(name)
      COMMANDS[name] || Client::Run
    end
  end
end

# allow users to add hooks that do not run in the server
# or modify start/stop
if File.exist?("config/spring_client.rb")
  require "./config/spring_client.rb"
end
