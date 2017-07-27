# spec/bronze/rails/resources/resource/base_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/base_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Resources::Resource::Base do
  include Spec::Resources::Resource::BaseExamples

  let(:described_class) do
    Class.new { include Bronze::Rails::Resources::Resource::Base }
  end # let
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new(resource_class, resource_options)
  end # let

  include_examples 'should implement the Resource::Base methods'
end # describe
