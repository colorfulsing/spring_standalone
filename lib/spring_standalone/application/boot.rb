# This is necessary for the terminal to work correctly when we reopen stdin.
Process.setsid

require "spring_standalone/application"

app = SpringStandalone::Application.new(
  UNIXSocket.for_fd(3),
  SpringStandalone::JSON.load(ENV.delete("SPRING_ORIGINAL_ENV").dup),
  SpringStandalone::Env.new(log_file: IO.for_fd(4))
)

Signal.trap("TERM") { app.terminate }

SpringStandalone::ProcessTitleUpdater.run { |distance|
  "spring standalone app    | #{app.app_name} | started #{distance} ago | #{app.app_env} mode"
}

app.eager_preload if ENV.delete("SPRING_PRELOAD") == "1"
app.run
