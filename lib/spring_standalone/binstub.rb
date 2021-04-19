command  = File.basename($0)
bin_path = File.expand_path("../../../bin/spring_sa", __FILE__)

if command == "spring_sa"
  load bin_path
else
  disable = ENV["DISABLE_SPRING"]

  if Process.respond_to?(:fork) && (disable.nil? || disable.empty? || disable == "0")
    ARGV.unshift(command)
    load bin_path
  end
end
