# spec/bronze/rails/resources/resource_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource/associations_examples'
require 'bronze/rails/resources/resource/base_examples'
require 'bronze/rails/resources/resource/names_examples'
require 'bronze/rails/resources/resource/routing_examples'
require 'bronze/rails/resources/resource/templates_examples'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource do
  include Spec::Resources::Resource::BaseExamples
  include Spec::Resources::Resource::AssociationsExamples
  include Spec::Resources::Resource::NamesExamples
  include Spec::Resources::Resource::RoutingExamples
  include Spec::Resources::Resource::TemplatesExamples

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new resource_class, resource_options
  end # let

  include_examples 'should implement the Resource::Base methods'

  include_examples 'should implement the Resource::Associations methods'

  include_examples 'should implement the Resource::Names methods'

  include_examples 'should implement the Resource::Routing methods'

  include_examples 'should implement the Resource::Templates methods'
end # describe
