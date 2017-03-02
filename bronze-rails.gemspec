# bronze-rails.gemspec

$: << './lib'
require 'bronze/rails/version'

Gem::Specification.new do |gem|
  gem.name        = 'bronze-rails'
  gem.version     = Bronze::Rails::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'Rails extensions for the Bronze application toolkit.'

  description = <<-DESCRIPTION
    Rails extensions and adapters for the Bronze application tools and patterns.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_runtime_dependency 'bronze', '~> 0.0'
  gem.add_runtime_dependency 'patina', '~> 0.0'
end # gemspec
