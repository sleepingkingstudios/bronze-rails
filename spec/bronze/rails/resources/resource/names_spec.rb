# spec/bronze/rails/resources/resource/names_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/resources/resource/names_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Resources::Resource::Names do
  include Spec::Resources::Resource::NamesExamples

  let(:described_class) do
    Class.new do
      include Bronze::Rails::Resources::Resource::Base
      include Bronze::Rails::Resources::Resource::Names
    end # class
  end # let
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new(resource_class, resource_options)
  end # let

  include_examples 'should implement the Resource::Names methods'
end # describe
