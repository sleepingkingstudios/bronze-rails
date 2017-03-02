# Gemfile

source 'https://rubygems.org'

bronze_options =
  if ENV['BRONZE'] == 'local'
    { :path => '../bronze' }
  else
    {
      :git    => 'https://github.com/sleepingkingstudios/bronze.git',
      :branch => 'master'
    } # end hash
  end # if-else

gem 'bronze', bronze_options
gem 'patina', bronze_options

group :doc do
  gem 'yard', '~> 0.9', '>= 0.9.5', :require => false
end # group

group :test do
  gem 'byebug', '~> 9.0', '~> 9.0.5'
end # group

gemspec :name => 'bronze-rails'
