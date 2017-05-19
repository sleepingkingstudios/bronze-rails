# spec/rails_helper.rb

ENV['RAILS_ENV'] ||= 'test'

require 'rails'

version     = "#{Rails::VERSION::MAJOR}_#{Rails::VERSION::MINOR}"
rails_path  = File.expand_path "rails_#{version}", __dir__
config_file = File.join(rails_path, 'config', 'environment')

unless File.exist?("#{config_file}.rb")
  # :nocov:
  abort("Unable to initialize Rails application at #{rails_path}")
  # :nocov:
end # unless

require 'support/scripts/copy_rails_files'

Spec::FileCopier.new(rails_path).call

require File.join(rails_path, 'config', 'environment')

# Prevent database truncation if the environment is production
if Rails.env.production?
  # :nocov:
  abort('The Rails environment is running in production mode!')
  # :nocov:
end # if

require 'spec_helper'
require 'rspec/rails'

RSpec.configure do |config|
  # Automatically mix in different behaviours to your tests based on their file
  # location.
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end # configure
