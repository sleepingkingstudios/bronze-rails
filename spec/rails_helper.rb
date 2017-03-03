# spec/rails_helper.rb

ENV['RAILS_ENV'] ||= 'test'

gemfile = File.split(ENV.fetch 'BUNDLE_GEMFILE', '').last
match   = gemfile.match(/\Arails_(?<version>\d_\d{1,2})\.gemfile\z/)

unless match && match[:version] && !match[:version].empty?
  # :nocov:
  raise 'Gemfile name does not indicate an installed version of Rails'
  # :nocov:
end # unless

rails_path =
  File.expand_path(
    File.join 'spec', "rails_#{match[:version]}", 'config', 'environment'
  ) # end rails_path

require File.expand_path(rails_path, __FILE__)

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
