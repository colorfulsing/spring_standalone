require 'thread'

module SpringStandalone
  class << self
    def failsafe_thread
      Thread.new {
        begin
          yield
        rescue
        end
      }
    end
  end
end
