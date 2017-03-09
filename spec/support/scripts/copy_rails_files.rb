# spec/support/scripts/copy_rails_files.rb

require 'fileutils'

module Spec
  class FileCopier
    def initialize rails_path
      @rails_path = File.expand_path rails_path
    end # method initialize

    def call
      puts 'Spec::FileCopier#call()'

      file_patterns.each { |pattern| copy_files pattern }
    end # method call

    private

    attr_reader :rails_path

    def copy_file source_name
      short_name  =
        source_name.dup.tap { |str| str[0..shared_path.length] = '' }
      target_name = File.join(rails_path, short_name)

      puts "  copying #{short_name} to #{target_name}"

      FileUtils.cp source_name, target_name
    end # method copy_files

    def copy_files pattern
      matching_files = Dir[File.join shared_path, pattern]
      matching_files.each do |file_name|
        copy_file file_name
      end # matching_files
    end # method copy_files

    def file_patterns
      [
        'config/routes.rb',
        'app/controllers/**/*.rb'
      ] # end patterns
    end # method file_patterns

    def shared_path
      @shared_path ||=
        File.expand_path(File.join rails_path, '..', 'rails_shared')
    end # method shared_path
  end # class
end # module
