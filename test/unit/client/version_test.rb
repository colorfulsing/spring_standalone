require_relative "../../helper"
require 'spring_standalone/client'

class VersionTest < ActiveSupport::TestCase
  test "outputs current version number" do
    version = SpringStandalone::Client::Version.new 'version'

    out, _ = capture_io do
      version.call
    end

    assert_equal "SpringStandalone version #{SpringStandalone::VERSION}", out.chomp
  end
end
