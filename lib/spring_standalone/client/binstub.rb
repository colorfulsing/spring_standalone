require 'set'

module SpringStandalone
  module Client
    class Binstub < Command
      SHEBANG = /\#\!.*\n(\#.*\n)*/

      # If loading the bin/spring_sa file works, it'll run SpringStandalone which will
      # eventually call Kernel.exit. This means that in the client process
      # we will never execute the lines after this block. But if the SpringStandalone
      # client is not invoked for whatever reason, then the Kernel.exit won't
      # happen, and so we'll fall back to the lines after this block, which
      # should cause the "unsprung" version of the command to run.
      LOADER = <<CODE
begin
  load File.expand_path('../spring_sa', __FILE__)
rescue LoadError => e
  raise unless e.message.include?('spring_sa')
end
CODE

      # The defined? check ensures these lines don't execute when we load the
      # binstub from the application process. Which means that in the application
      # process we'll execute the lines which come after the LOADER block, which
      # is what we want.
      SPRING = <<'CODE'
#!/usr/bin/env ruby

# This file loads SpringStandalone without using Bundler, in order to be fast.
# It gets overwritten when you run the `spring_sa binstub` command.

unless defined?(SpringStandalone)
  require 'rubygems'
  require 'bundler'

  lockfile = Bundler::LockfileParser.new(Bundler.default_lockfile.read)
  spring_standalone = lockfile.specs.detect { |spec| spec.name == 'spring_standalone' }
  if spring_standalone
    Gem.use_paths Gem.dir, Bundler.bundle_path.to_s, *Gem.path
    gem 'spring_standalone', spring_standalone.version
    require 'spring_standalone/binstub'
  end
end
CODE

      OLD_BINSTUB = %{if !Process.respond_to?(:fork) || Gem::Specification.find_all_by_name("spring").empty?}

      BINSTUB_VARIATIONS = Regexp.union [
        %{begin\n  load File.expand_path('../spring_sa', __FILE__)\nrescue LoadError\nend\n},
        %{begin\n  spring_bin_path = File.expand_path('../spring_sa', __FILE__)\n  load spring_bin_path\nrescue LoadError => e\n  raise unless e.message.end_with? spring_bin_path, 'spring_standalone/binstub'\nend\n},
        LOADER
      ].map { |binstub| /#{Regexp.escape(binstub).gsub("'", "['\"]")}/ }

      class Item
        attr_reader :command, :existing

        def initialize(command)
          @command = command

          if command.binstub.exist?
            @existing = command.binstub.read
          # elsif command.name == "rails"
          #   scriptfile = SpringStandalone.application_root_path.join("script/rails")
          #   @existing = scriptfile.read if scriptfile.exist?
          end
        end

        def status(text, stream = $stdout)
          stream.puts "* #{command.binstub_name}: #{text}"
        end

        def add
          if existing
            if existing.include?(OLD_BINSTUB)
              fallback = existing.match(/#{Regexp.escape OLD_BINSTUB}\n(.*)else/m)[1]
              fallback.gsub!(/^  /, "")
              fallback = nil if fallback.include?("exec")
              generate(fallback)
              status "upgraded"
            elsif existing.include?(LOADER)
              status "SpringStandalone already present"
            elsif existing =~ BINSTUB_VARIATIONS
              upgraded = existing.sub(BINSTUB_VARIATIONS, LOADER)
              File.write(command.binstub, upgraded)
              status "upgraded"
            else
              head, shebang, tail = existing.partition(SHEBANG)

              if shebang.include?("ruby")
                unless command.binstub.exist?
                  FileUtils.touch command.binstub
                  command.binstub.chmod 0755
                end

                File.write(command.binstub, "#{head}#{shebang}#{LOADER}#{tail}")
                status "SpringStandalone inserted"
              else
                status "doesn't appear to be ruby, so cannot use SpringStandalone", $stderr
                exit 1
              end
            end
          else
            generate
            status "generated with SpringStandalone"
          end
        end

        def generate(fallback = nil)
          unless fallback
            fallback = "require 'bundler/setup'\n" \
                       "load Gem.bin_path('#{command.gem_name}', '#{command.exec_name}')\n"
          end

          File.write(command.binstub, "#!/usr/bin/env ruby\n#{LOADER}#{fallback}")
          command.binstub.chmod 0755
        end

        def remove
          if existing
            File.write(command.binstub, existing.sub(BINSTUB_VARIATIONS, ""))
            status "SpringStandalone removed"
          end
        end
      end

      attr_reader :bindir, :items

      def self.description
        "Generate SpringStandalone based binstubs. Use --all to generate a binstub for all known commands. Use --remove to revert."
      end

      # def self.rails_command
      #   @rails_command ||= CommandWrapper.new("rails")
      # end

      def self.call(args)
        require "spring_standalone/commands"
        super
      end

      def initialize(args)
        super

        @bindir = env.root.join("bin")
        @all    = false
        @mode   = :add
        @items  = args.drop(1)
                      .map { |name| find_commands name }
                      .inject(Set.new, :|)
                      .map { |command| Item.new(command) }
      end

      def find_commands(name)
        case name
        when "--all"
          @all = true
          commands = SpringStandalone.commands.dup
          commands.values
          # commands.delete_if { |command_name, _| command_name.start_with?("rails_") }
          # commands.values + [self.class.rails_command]
        when "--remove"
          @mode = :remove
          []
        # when "rails"
        #   [self.class.rails_command]
        else
          if command = SpringStandalone.commands[name]
            [command]
          else
            $stderr.puts "The '#{name}' command is not known to spring_standalone."
            exit 1
          end
        end
      end

      def call
        case @mode
        when :add
          bindir.mkdir unless bindir.exist?

          File.write(spring_sa_binstub, SPRING)
          spring_sa_binstub.chmod 0755

          items.each(&:add)
        when :remove
          spring_sa_binstub.delete if @all
          items.each(&:remove)
        else
          raise ArgumentError
        end
      end

      def spring_sa_binstub
        bindir.join("spring_sa")
      end
    end
  end
end
