require_relative "../../helper"

require 'spring_standalone/client/command'
require 'spring_standalone/client/help'
require 'spring_standalone/client'

class HelpTest < ActiveSupport::TestCase
  def spring_commands
    {
      'command' => Class.new {
        def self.description
          'Random SpringStandalone Command'
        end
      },
      'rails' => Class.new {
        def self.description
          "omg"
        end
      }
    }
  end

  def application_commands
    {
      'random' => Class.new {
        def description
          'Random Application Command'
        end
      }.new,
      'hidden' => Class.new {
        def description
          nil
        end
      }.new
    }
  end

  def setup
    @help = SpringStandalone::Client::Help.new('help', spring_commands, application_commands)
  end

  test "formatted_help generates expected output" do
    expected_output = <<-EOF
Version: #{SpringStandalone::VERSION}

Usage: spring COMMAND [ARGS]

Commands for SpringStandalone itself:

  command  Random SpringStandalone Command

Commands for your application:

  rails    omg
  random   Random Application Command
    EOF

    assert_equal expected_output.chomp, @help.formatted_help
  end
end
