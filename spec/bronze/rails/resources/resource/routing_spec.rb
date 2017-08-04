# spec/bronze/rails/resources/resource/routing_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/resources/resource/routing'
require 'bronze/rails/resources/resource/routing_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Resources::Resource::Routing do
  include Spec::Resources::Resource::RoutingExamples

  let(:described_class) do
    Class.new do
      include Bronze::Rails::Resources::Resource::Base
      include Bronze::Rails::Resources::Resource::Names
      include Bronze::Rails::Resources::Resource::Routing
    end # class
  end # let
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new(resource_class, resource_options)
  end # let

  include_examples 'should implement the Resource::Routing methods'
end # describe
