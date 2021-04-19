require_relative "../helper"
require "spring_standalone/commands"

class CommandsTest < ActiveSupport::TestCase
  test 'console command sets rails environment from command-line option' do
    command = SpringStandalone::Commands::RailsConsole.new
    assert_equal 'test', command.env(['test'])
  end

  test 'console command sets rails environment from -e option' do
    command = SpringStandalone::Commands::RailsConsole.new
    assert_equal 'test', command.env(['-e', 'test'])
  end

  test 'console command sets rails environment from --environment option' do
    command = SpringStandalone::Commands::RailsConsole.new
    assert_equal 'test', command.env(['--environment=test'])
  end

  test 'console command ignores first argument if it is a flag except -e and --environment' do
    command = SpringStandalone::Commands::RailsConsole.new
    assert_nil command.env(['--sandbox'])
  end

  test 'Runner#env sets rails environment from command-line option' do
    command = SpringStandalone::Commands::RailsRunner.new
    assert_equal 'test', command.env(['-e', 'test', 'puts 1+1'])
  end

  test 'RailsRunner#env sets rails environment from long form of command-line option' do
    command = SpringStandalone::Commands::RailsRunner.new
    assert_equal 'test', command.env(['--environment=test', 'puts 1+1'])
  end

  test 'RailsRunner#env ignores insignificant arguments' do
    command = SpringStandalone::Commands::RailsRunner.new
    assert_nil command.env(['puts 1+1'])
  end

  test 'RailsRunner#extract_environment removes -e <env>' do
    command = SpringStandalone::Commands::RailsRunner.new
    args = ['-b', '-a', '-e', 'test', '-r']
    assert_equal [['-b', '-a', '-r'], 'test'], command.extract_environment(args)
  end

  test 'RailsRunner#extract_environment removes --environment=<env>' do
    command = SpringStandalone::Commands::RailsRunner.new
    args = ['-b', '--environment=test', '-a', '-r']
    assert_equal [['-b', '-a', '-r'], 'test'], command.extract_environment(args)
  end

  test "rake command has configurable environments" do
    command = SpringStandalone::Commands::Rake.new
    assert_nil command.env(["foo"])
    assert_equal "test", command.env(["test"])
    assert_equal "test", command.env(["test:models"])
    assert_nil command.env(["test_foo"])
  end

  test 'RailsTest#command defaults to test rails environment' do
    command = SpringStandalone::Commands::RailsTest.new
    assert_equal 'test', command.env([])
  end

  test 'RailsTest#command sets rails environment from --environment option' do
    command = SpringStandalone::Commands::RailsTest.new
    assert_equal 'foo', command.env(['--environment=foo'])
  end

  test 'RailsTest#command sets rails environment from -e option' do
    command = SpringStandalone::Commands::RailsTest.new
    assert_equal 'foo', command.env(['-e', 'foo'])
  end
end
