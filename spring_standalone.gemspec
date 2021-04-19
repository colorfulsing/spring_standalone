require './lib/spring_standalone/version'

Gem::Specification.new do |gem|
  gem.name          = "spring_standalone"
  gem.version       = SpringStandalone::VERSION
  gem.authors       = ["Eduardo Rosales"]
  gem.email         = ["eduardo@datahen.com"]
  gem.summary       = "Ruby application preloader"
  gem.description   = "Forked from 'spring' gem, it preloads your application so commands run faster"
  gem.homepage      = "https://github.com/colorfulsing/spring_standalone"
  gem.license       = "MIT"

  gem.files         = Dir["LICENSE.txt", "README.md", "lib/**/*", "bin/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  gem.required_ruby_version = ">= 2.5.0"

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bump'
  # gem.add_development_dependency 'activesupport'
end
