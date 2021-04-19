require "bundler/setup"
require "minitest/autorun"

require_relative "support/test"
SpringStandalone::Test.root = File.expand_path('..', __FILE__)
