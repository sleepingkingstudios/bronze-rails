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

  gem.add_runtime_dependency 'sleeping_king_studios-tools',
    '>= 0.6.0.rc.0', '< 0.7.0'

  gem.add_development_dependency 'rake',      '~> 12.0'
  gem.add_development_dependency 'thor',      '~> 0.19',  '>= 0.19.1'
  gem.add_development_dependency 'appraisal', '~> 2.1.0'
  gem.add_development_dependency 'rspec',     '~> 3.5'
  gem.add_development_dependency 'rspec-sleeping_king_studios',
    '~> 2.2', '>= 2.2.1'
  # See https://github.com/bbatsov/rubocop
  gem.add_development_dependency 'rubocop',   '~> 0.47.0'
  gem.add_development_dependency 'simplecov', '~> 0.12'
end # gemspec
